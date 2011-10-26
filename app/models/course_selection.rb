class CourseSelection < ActiveRecord::Base
  belongs_to :schedule
  belongs_to :section

  def course
    section.course
  end

  def number
    course.number
  end

  def name
    course.name
  end

  def selected_section
    section.letter
  end
end
