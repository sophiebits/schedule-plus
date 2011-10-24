class Semester < ActiveRecord::Base
  
  # returns the current semester
  def self.current
    Semester.find_by_current(true)
  end
end
