class Semester < ActiveRecord::Base
  has_many :courses
  
  # returns the current semester
  def self.current
    Semester.find_by_current(true)
  end
  
  def self.current_name_short
    sem = Semester.find_by_current(true)
    if sem
      sem_name = sem.name
      # "Spring 2012" ==> "S" + "12" ==> "S12"
      return sem_name[0]+sem_name[-2,2]
    end
    ""
  end
end
