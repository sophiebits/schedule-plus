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

	def as_json(options={})
    hash = {
      :id => self.id,
      :uid => self.uid,
      :name => self.name,
      :status => self.status
    }
    hash
  end
  
  ##########################
  # Course + Status Queries
  ##########################
  
  def in_course(course)
    main_schedule.scheduled_courses.map(&:course).each do |my_course|   
      return true if my_course == course
    end
    false
  end
  
  def courses_in_common(friend)
    user_courses = self.main_schedule.scheduled_courses.collect{|sc| sc.course}
    friend_courses = friend.main_schedule.scheduled_courses.collect{|sc| sc.course}
    
    user_courses & friend_courses
  end
  
  def status
    return '' if !self.main_schedule
    
		current_time = Time.now.in_time_zone
		current_time_in_min = current_time.hour*60 + current_time.min
		current_time_in_min = 750
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
			return 'in ' + number + ' ' + section
		end
	end
	
	def free?
	  self.status == 'free'
	end

  ###################
  # Schedule Methods
  ###################

  def update_active_schedule(schedule)
    if schedule.user_id == -1
      schedule.update_attribute(:user_id, self.id)
      schedule.save
    elsif schedule.user != self
      return nil
    end 
			
    # Find the user's active schedule and update it to be the imported
	  # schedule, or create a new active schedule
		active_schedule = ActiveSchedule.find_by_user_id(self.id)
		if active_schedule
			active_schedule.update_attribute(:schedule_id, schedule.id)
			active_schedule.save
		else
			ActiveSchedule.create(:user_id => self.id, :schedule_id => schedule.id)
		end
    
    schedule
  end
end
