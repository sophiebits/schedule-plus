class CourseSelection < ActiveRecord::Base
  belongs_to :schedule
  belongs_to :scheduled_course
end
