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
             name LIKE ?', 
              "%#{search}%",
              "%#{search}%")
    else
      scoped
    end
  end

  def sections_by_lecture
    # FIXME: does not include lectures with no sections
    sections.group_by{ |s| s.lecture }
  end
  
  def find_by_section(name)
    sections.find_by_letter(name)
  end

  def prereqs_str
    prereqs || "Not Available"
  end

  def coreqs_str
    coreqs || "Not Available"
  end

  def description_str
    description || "Not Available"
  end

  def instructors
    if lectures.empty?
      instructors = sections.map(&:instructor)
    else
      instructors = lectures.map(&:instructor)
    end
    instructors.uniq.compact.join(", ")
  end

  def students
    schedules.active.map(&:user) 
  end
end
