class Lecture < ActiveRecord::Base
  belongs_to :course
  has_many :sections
  has_many :times, :class_name => 'ScheduledTime'
                 , :as => :schedulable
  has_many :course_selections
  has_many :schedules, :through => :course_selections

  def as_json(options={})
    {
      :number   => self.number,
      :times    => self.times,
      :students => self.students
    }
  end

  # finds students in a lecture
  def students
    schedules.active.map(&:user)
  end
end
