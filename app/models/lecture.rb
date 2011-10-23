class Lecture < ActiveRecord::Base
  belongs_to :course
  has_many :sections
  has_many :times, :class_name => 'ScheduledTime'
                 , :as => :schedulable
  has_many :course_selections
  has_many :schedules, :through => :course_selections

  def students
    schedules.active.map(&:user)
  end
end
