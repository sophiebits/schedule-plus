class Schedule < ActiveRecord::Base
  belongs_to :scheduled_course
  belongs_to :user
end
