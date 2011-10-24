class Semester < ActiveRecord::Base
  has_many :courses
  
  # returns the current semester
  def self.current
    Semester.find_by_current(true)
  end
end
