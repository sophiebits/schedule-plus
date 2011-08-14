class Schedule < ActiveRecord::Base
  has_many :course_selections
  has_many :scheduled_courses, :through => :course_selections
  belongs_to :user
end
