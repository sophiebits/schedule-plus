class Course < ActiveRecord::Base
  has_many :user_to_courses
  has_many :users, :through => :user_to_courses

end
