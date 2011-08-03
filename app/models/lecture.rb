class Lecture < ActiveRecord::Base
  belongs_to :course
  has_many :scheduled_courses
  has_many :recitations
  has_many :lecture_section_times
end
