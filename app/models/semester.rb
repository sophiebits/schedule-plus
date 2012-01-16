class Semester < ActiveRecord::Base
  has_many :courses
  has_many :schedules
  
  # returns the current semester
  def self.current
    Semester.find_by_current(true)
  end

  def to_param
    short_name
  end
end
