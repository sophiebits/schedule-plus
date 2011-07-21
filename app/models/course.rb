class Course < ActiveRecord::Base
  attr_accessible :course_number, :section, :name, :description, :units, :lecture_time, :lecture_duration, :lecture_datys, :lecture_room, :recitatino_time, :recitation_duration, :recitation_room, :recitation_days
  
  belongs_to :schedule

end
