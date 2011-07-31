class ScheduledCourse < ActiveRecord::Base
  has_many :users, :through => :schedules
  belongs_to :course
end
