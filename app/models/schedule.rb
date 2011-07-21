class Schedule < ActiveRecord::Base
  attr_accessible :student_id, :course_id

  has_many :students
  has_many :courses
end
