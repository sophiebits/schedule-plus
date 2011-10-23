class Course < ActiveRecord::Base
  has_many :sections
  has_many :lectures
  has_many :course_selections
  has_many :schedules, :through => :course_selections
  
  def find_by_section(name)
    self.sections.find_by_name(name)
  end

  def students
    schedules.active.map(&:user) 
  end
end
