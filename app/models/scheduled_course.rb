class ScheduledCourse < ActiveRecord::Base
  has_many :schedules, :through => :course_selections
  has_many :users, :through => :schedules
  
  belongs_to :course
  belongs_to :lecture
  belongs_to :recitation
end
