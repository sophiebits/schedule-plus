class Course < ActiveRecord::Base
  has_many :sections
  has_many :lectures
  has_many :course_selections, :through => :sections
  belongs_to :semester
  belongs_to :department
  scope :by_semester, lambda {|sem| where(:semester_id => sem.id)}
  scope :by_department, lambda {|dep_id| where(:department_id => dep_id) if dep_id }

  before_create :add_department
  
  def to_param
    number
  end

  # RailsCast 240
  def self.search(search)
    if search
      search = search.gsub('-', '').strip
      result = where("REPLACE(number, '-', '') LIKE ?", "%#{search}%")
      if result.empty?
      	terms = search.split
      	result = terms.inject(scoped) do |combined_scope, term|	
      		combined_scope.where("name LIKE ?", "%#{term}%")
      	end
      end
      return result
    else
      scoped
    end
  end

  def sections_by_lecture
    # FIXME: does not include lectures with no sections
    sections.group_by(&:lecture)
  end
  
  def find_by_section(name)
    sections.find_by_letter(name)
  end

  def prereqs_str
    "Not Available" if prereqs.nil? || prereqs.empty?
  end

  def coreqs_str
    "Not Available" if coreqs.nil? || coreqs.empty?
  end

  def description_str
    "Not Available" if description.nil? || description.empty?
  end

  def instructors
    if lectures.empty?
      instructors = sections.map(&:instructor)
    else
      instructors = lectures.map(&:instructor)
    end
    instructors.uniq.compact.join(", ")
  end

  def students(semester=nil)
    course_selections.map(&:schedule)
                     .select {|s| s.primary && (semester.nil? || s.semester == semester) }
                     .map(&:user)
  end
  
  def add_department
    dep = Department.where("prefix LIKE ?", "%#{self.number[0..1]}%").first
    if dep
      self.department_id = dep.id
      true
    else
      false
    end
  end
end
