class Section < ActiveRecord::Base
  belongs_to :course
  belongs_to :lecture # optional lecture requisite
  has_many :times, :class_name => 'ScheduledTime'
                 , :as => :schedulable
  has_many :course_selections
  has_many :schedules, :through => :course_selections

  def as_json(options={})
    {
      :name     => self.name,
      :times    => self.times,
      :students => self.students
    }
  end

  # finds students in a section
  def students
    schedules.active.map(&:user)
  end
end
