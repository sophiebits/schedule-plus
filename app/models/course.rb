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
      result = where("REPLACE(number, '-', '') " + Rails.application.config.like_operator + " ?", "%#{search}%")
      if result.empty?
        terms = search.split
        result = terms.inject(scoped) do |combined_scope, term| 
          combined_scope.where("name " + Rails.application.config.like_operator + " ?", "%#{term}%")
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
    fill prereqs
  end

  def coreqs_str
    fill coreqs
  end

  def description_str
    fill description
  end

  def instructors
    if lectures.empty?
      instructors = sections.map(&:instructor)
    else
      instructors = lectures.map(&:instructor)
    end
    instructors.uniq.compact.join(", ")
  end

  def students(semester=nil, user=nil, option="all")
    # option can be "all", "friends", or "others"
    if semester
      cs = Course.find_by_number_and_semester_id(number, semester.id).try(:course_selections) || []
    else
      cs = Course.find_all_by_number(number).map(&:course_selections).flatten
    end
    students = cs.map(&:schedule).select(&:primary).map(&:user)
    if option == "friends"
      students = students.select {|s| user.friends_with? s}
    elsif option == "others"
      students = students.select {|s| !user.friends_with? s}
    end
    if user.nil?
      students
    else
      students.sort_by {|u| [(u != user).to_s, (!user.friends_with? u).to_s, u.first_name, u.last_name] }
    end
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

  private

  def fill(str)
    if str.nil? || str.empty?
      "Not Available."
    else
      str
    end
  end
end
