class Section < ActiveRecord::Base
  belongs_to :course
  belongs_to :lecture # optional lecture requisite
  has_many :scheduled_times, :class_name => 'ScheduledTime', :as => :schedulable
  has_many :course_selections
  has_many :schedules, :through => :course_selections

  def as_json(options={})
    {
      :name     => self.name,
      :scheduled_times    => self.scheduled_times,
      :students => self.students
    }
  end

  # finds students in a section
  def students
    schedules.primary.map(&:user)
  end
end
