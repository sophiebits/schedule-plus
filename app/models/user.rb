class User < ActiveRecord::Base
  has_many :schedules
  has_many :active_schedules # by semester
  has_many :main_schedules, :through => :active_schedules, 
                            :source => :schedule

  def in_course?(course)
    
  end

  def update_active_schedule(schedule)
    if (schedule.user == self)
      active_schedules.find_by_semester(schedule.semester)
                      .update_attribute(:active,false)
                      .save
      schedule.update_attribute(:active,true).save
    end
  end
end
