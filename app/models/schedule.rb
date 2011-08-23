class Schedule < ActiveRecord::Base
  has_many :course_selections
  has_many :scheduled_courses, :through => :course_selections
  has_many :lectures, :through => :scheduled_courses
  has_many :recitations, :through => :scheduled_courses
  belongs_to :user

  def as_json(options={})
    {
     :id                => self.id,
     :user              => self.user,
     :scheduled_courses => self.scheduled_courses
    }
  end
end
