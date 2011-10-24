class Course < ActiveRecord::Base
  has_many :sections
  has_many :lectures
  has_many :course_selections
  has_many :schedules, :through => :course_selections
  belongs_to :semester
  
  # RailsCast 240
  def self.search(search)
    if search
      # sphinx?
      where('number LIKE ? or
             name LIKE ? or 
             instructor LIKE ?', 
              "%#{search}%",
              "%#{search}%",
              "%#{search}%")
    else
      scoped
    end
  end

  def sections_by_lecture
    sections.group_by{ |s| s.lecture }
  end
  
  def find_by_section(name)
    self.sections.find_by_name(name)
  end

  def students
    schedules.active.map(&:user) 
  end
end
