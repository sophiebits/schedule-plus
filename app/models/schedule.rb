class Schedule < ActiveRecord::Base
  has_many :course_selections
  has_many :scheduled_courses, :through => :course_selections
  belongs_to :user
  
  def units
    units_lower = 0
    units_upper = 0
    self.scheduled_courses.each do |sc|
      units = sc.course.units.split('-')
      lower = units[0].to_f
      upper = units[-1].to_f
      units_lower += lower
      units_upper += upper
    end
    
    if units_lower == units_upper
      return units_lower.to_s
    else
      return units_lower.to_s + '-' + units_upper.to_s
    end
  end
end
