require 'rubygems'
require 'ri_cal'
require 'net/http'
require 'open-uri'
require 'openssl'
require 'hpricot'

def getsection(sec)
	if sec.include? 'Lec'
		if sec == 'Lec'
			return '1'
		end
		return sec[-1,1]
	end
	sec
end

class Parser < ActiveRecord::Base
  
  # Parse method for SIO calendar file
  def self.parseSIO(file, current_user_id = -1)
    @components = RiCal.parse(file)
    
    scheduled_courses = Hash.new
    
    @components.first.events.each do |course| 
      summary = course.summary.split('::')[1].strip.split(' ')
      
      if summary.count > 0
        number = summary[0].insert(2,'-')
        section = summary[1]
      
        if !(scheduled_courses[number])
  				scheduled_courses[number] = Hash.new
  			end
      
        # If course section is a number, assume lecture section; otherwise
        # assume recitation section
        if section.to_i != 0
  				scheduled_courses[number][:lecture_section] = section
        else
          scheduled_courses[number][:recitation_section] = section
        end
      end
    end
    
    self.check_errors(self.generate_schedule_response(scheduled_courses, current_user_id))
  end

  # Parse method for scheduleman url
  def self.parse(url, current_user_id = -1)
    #if the link has a trailing '/' remove it
    if (url[url.length-1] == '/')
       url[url.length-1] = ''
    end
 
    #if the url has a trailing '.ics' remove it
    if ((url[url.length-4,url.length-1]).eql?(".ics"))
       url = url[0..(url.length-5)]
    end

    #if the url is http, add in the 's' to make it https
    if ((url[0..4]).eql?("http:"))
       url = "https" + url[4..(url.length-1)]
    end

    #if the url doesnt have any http/https protocal prefix, add it
    if (!url.include?("https://"))
       url = "https://" + url
    end

    #append .ics to get the file from scheduleman server, not the html code
    file_url = url + ".ics"
	
		scheduled_courses = Hash.new
		
    open(file_url) do |file|
      @components = RiCal.parse(file)
    end 
      
    @components.first.events.each do |course| 
      summary = course.summary.delete('"').split(' ')
      
      if summary.include? "Lec"
				number = summary[-2]
				if number == "Lec"
					number = summary[-3]
				end
			
			  if !(scheduled_courses[number])
  				scheduled_courses[number] = Hash.new
  			end
  			
				section = getsection(summary[-1])
				scheduled_courses[number][:lecture_section] = section
			else
				number = summary[-2]
				section = getsection(summary[-1])
        
        if !(scheduled_courses[number])
  				scheduled_courses[number] = Hash.new
  			end
  			
				scheduled_courses[number][:recitation_section] = section
			end
    end   
    
    response = self.generate_schedule_response(scheduled_courses, current_user_id)
    
    # Need to check for TBA courses in scheduleman
    doc = open(url) { |f| Hpricot(f) }
    total_units = (doc/"#total-units").first.inner_text
    
    if total_units
      total_units = total_units[/.*total:(.*?)units/,1].strip
      if response[:schedule].units != total_units
        # Units are different; need to parse TBA courses on the scheduleman
        courses = (doc/".course")
        scheduled_course_numbers = response[:schedule].scheduled_courses.collect{|sc| sc.course.number}

        # Check each course in tehe html to find which one's aren't included in the user's schedule
        courses.each do |c|
          number = (c/".number").inner_text.strip[0,6]
          if !scheduled_course_numbers.include? number
            section = (c/".selected_section").inner_text.strip
            
            tba_course = Course.find_by_number(number)
            recitation = Recitation.where(:lecture_id => tba_course.lectures, :section => section)
            lecture = nil
            if recitation && recitation.first
              lecture = recitation.first.lecture
              recitation = recitation.first
            else
              lecture = Lecture.where(:course_id => tba_course, :section => section).first
              recitation = nil
            end
            
            # Manually add TBA course to schedule
            self.add_to_schedule(tba_course, response[:schedule], lecture, recitation)
          end
        end
      end
    end
    
    self.check_errors(response)
	end
	
	def self.check_errors(response)
		# Check that schedule doesn't have over 100 units
		if !response[:schedule].valid_units
		  response[:error] = "Schedule is too large (total units are over 100)"
		end
		
		response
  end
	
	def self.generate_schedule_response(scheduled_courses, current_user_id)
    response = Hash.new
    response[:warnings] = []
    schedule = Schedule.create(:user_id => current_user_id)

		# Create scheduled courses
		scheduled_courses.each do |number,sections|
			course = Course.find_by_number(number)
			
		  if !course
        Logger.new(STDOUT).info(number + ' does not exist in db!')
        response[:warnings].push(number)
        next
      end

			lec_id = nil
			rec_id = nil
			
			# Get the lec and rec ids
			if sections[:lecture_section]
				lecture = course.lectures.find_by_section(sections[:lecture_section])
				if lecture
          recitation = lecture.recitations.find_by_section(sections[:recitation_section])
        end
			else
				lecture = course.lectures.find_by_section(sections[:recitation_section])
			end

      if !lecture || (sections[:lecture_section] && !recitation)
        Logger.new(STDOUT).info(number + ' is inconsistent with ScheduleMan.')
        response[:warnings].push(number)
        next
      end
			
      self.add_to_schedule(course, schedule, lecture, recitation)
		end

    response[:schedule] = schedule
    response
  end
  
  def self.add_to_schedule(course, schedule, lecture, recitation)
    lec_id = lecture.try(:id)
    rec_id = recitation.try(:id)

		# Get the scheduled course if it already exists
		sc = nil
		if lec_id && rec_id
			sc = course.scheduled_courses.find_by_lecture_id_and_recitation_id(lec_id,rec_id)
		else
			sc = course.scheduled_courses.find_by_lecture_id(lec_id)
		end
		
		if !sc
			sc = ScheduledCourse.create(:course_id => course.id, :lecture_id => lec_id, :recitation_id => rec_id)
		end

    CourseSelection.create(:schedule_id => schedule.id, :scheduled_course_id => sc.id)
  end

end
