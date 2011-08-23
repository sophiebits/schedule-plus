class ScheduledCourse < ActiveRecord::Base
  has_many :schedules, :through => :course_selections
  has_many :users, :through => :schedules
  
  belongs_to :course
  belongs_to :lecture
  belongs_to :recitation

  def as_json(options={})
    {
      :id => self.id,
      :course => self.course,
      :lecture => self.lecture,
      :recitation => self.recitation
    }
  end
end
