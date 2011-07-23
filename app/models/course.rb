class Course < ActiveRecord::Base
  attr_accessible :course_number, :section, :name, :description, :units, :lecture_time, :lecture_duration, :lecture_days, :lecture_room, :recitation_time, :recitation_duration, :recitation_room, :recitation_days
  
  belongs_to :schedule

end
