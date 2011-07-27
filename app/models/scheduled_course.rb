class ScheduledCourse < ActiveRecord::Base
  has_many :scheduled_course_to_users
  has_many :users, :through => :scheduled_course_to_users
end
