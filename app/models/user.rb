require 'open-uri'

class User < ActiveRecord::Base
  has_one :active_schedule
  has_one :main_schedule, :through => :active_schedule, :source => :schedule
  has_many :schedules
  has_many :scheduled_courses, :through => :main_schedule

	DAY_NAME = %w(Sunday Monday Tuesday Wednesday Thursday Friday Saturday)
  
  def self.create_with_omniauth(auth)
    create! do |user|
      user.uid = auth["uid"]
      user.name = auth["user_info"]["name"]
    end
  end

	def status
		current_time = Time.now.in_time_zone
		current_time_in_min = current_time.hour*60 + current_time.min
		current_day = DAY_NAME[current_time.wday]
	
		scheduled_courses = self.main_schedule.scheduled_courses.includes(
		  :lecture => :lecture_section_times, 
			:recitation => :recitation_section_times,
			:course => [])
			
		active_scheduled_course_lectures = scheduled_courses.where('lecture_section_times.begin <= ? AND lecture_section_times.end >= ? AND lecture_section_times.day = ?',
			current_time_in_min, current_time_in_min, current_day)
		
		active_scheduled_course_recitations = scheduled_courses.where('recitation_section_times.begin <= ? AND recitation_section_times.end >= ? AND recitation_section_times.day = ?',
			current_time_in_min, current_time_in_min, current_day)
			
		number = ''
		section = ''
		if active_scheduled_course_lectures.length > 0
			active_scheduled_course = active_scheduled_course_lectures[0]
			number = active_scheduled_course_lectures[0].course.number
			section = active_scheduled_course_lectures[0].lecture.section
			if active_scheduled_course.recitation
				section = 'Lec ' + section
			end
		elsif active_scheduled_course_recitations.length > 0
			active_scheduled_course = active_scheduled_course_recitations[0]
			number = active_scheduled_course.course.number
			section = active_scheduled_course.recitation.section
		end
		
		if number == ''
			return 'free'
		else
			return 'in' + number + ' ' + section
		end
	end
end
