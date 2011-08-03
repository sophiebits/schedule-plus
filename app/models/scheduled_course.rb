class ScheduledCourse < ActiveRecord::Base
  has_many :schedules
  has_many :users, :through => :schedules
  belongs_to :course
  belongs_to :lecture
  belongs_to :recitation
end
