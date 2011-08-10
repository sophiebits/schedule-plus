require 'rubygems'
require 'ri_cal'
require 'net/http'

def getsection(sec)
	if sec.include? 'Lec'
		if sec == 'Lec'
			return '1'
		end
		return sec[-1,1]
	end
	sec
end

class Parser

  def self.parse(file, current_user_id)
	
		scheduled_courses = Hash.new
		
    File.open(file,"r") do |file|
      @components = RiCal.parse(file)
    end 
      
    @components.first.events.each do |course| 
      summary = course.summary.delete('"')

      if summary.include? "Lec"
	
				number = summary.split(" ")[-2].delete('-')
				if number == "Lec"
					number = summary.split(" ")[-3].delete('-')
				end
				
				section = getsection(summary.split(" ")[-1])
				
				if !(scheduled_courses[number])
					scheduled_courses[number] = Hash.new
				end
				
				scheduled_courses[number][:lecture_section] = section
			else
				number = summary.split(" ")[-2].delete('-')
				section = getsection(summary.split(" ")[-1])
				if !(scheduled_courses[number])
					scheduled_courses[number] = Hash.new
				end
				scheduled_courses[number][:recitation_section] = section
			end
    end   

		# Create scheduled courses
		scheduled_courses.each do |number,sections|
			course = Course.find_by_number(number)
			
			abort "Course #{number} is not in the db!" if !course
			
			lec_id = nil
			rec_id = nil
			
			# Get the lec and rec ids
			if sections[:lecture_section]
				lec_id = course.lectures.find_by_section(sections[:lecture_section]).id
				rec_id = course.lectures.find(lec_id).recitations.find_by_section(sections[:recitation_section]).id
			else
				lec_id = course.lectures.find_by_section(sections[:recitation_section]).id
			end
			
			# Get the scheduled course if it already exists
			sc = nil
			if lec_id && rec_id
				sc = course.scheduled_courses.find_by_lecture_id_and_recitation_id(lec_id,rec_id)
			else
				sc = course.scheduled_courses.find_by_lecture_id(lec_id)
			end
			
			if sc
				Schedule.create(:scheduled_course_id => sc.id, :user_id => current_user_id)
			else
				sc = ScheduledCourse.create(:course_id => course.id, :lecture_id => lec_id, :recitation_id => rec_id)
				Schedule.create(:scheduled_course_id => sc.id, :user_id => current_user_id)
			end
		end
  end

end
