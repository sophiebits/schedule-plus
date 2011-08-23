class Lecture < ActiveRecord::Base
  belongs_to :course
  has_many :scheduled_courses
  has_many :recitations
  has_many :lecture_section_times

  def as_json(options={})
    {
      :section => self.section,
      :lecture_section_times => self.lecture_section_times
    }
  end
end
