require 'rubygems'
require 'ri_cal'
require 'net/http'
require 'open-uri'
require 'openssl'

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
  def self.parseSIO(file_path, current_user_id = -1)
    File.open(file_path, 'r') do |file|
      @components = RiCal.parse(file)
    end
    
    scheduled_courses = Hash.new
    
    @components.first.events.each do |course| 
      summary = course.summary.split('::')[1].strip.split(' ')
      
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
    
    self.generate_schedule_response(scheduled_courses, current_user_id)
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
    url = url + ".ics"
	
		scheduled_courses = Hash.new
		
    open(url) do |file|
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
			
			p scheduled_courses
    end   
    
    self.generate_schedule_response(scheduled_courses, current_user_id)
	end
	
	def self.generate_schedule_response(scheduled_courses, current_user_id)
    response = Hash.new
    response[:warnings] = []
    schedule = Schedule.create(:user_id => current_user_id)

    p scheduled_courses

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

    response[:schedule] = schedule
    response
  end

end
