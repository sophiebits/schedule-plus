class Schedule < ActiveRecord::Base
  belongs_to :user
  has_many :courses, :class_name => 'CourseSelection'
  scope :active, :conditions => { :active => true }
 
  def as_json(options={})
    {
      :id      => self.id,
      :user    => self.user,
      :courses => self.courses,
      :active  => self.active
    }
  end

  def units
    # TODO
    "0.0"
  end

  # Adds a course by course_id and section_id.
  # Assumes course_id and section_id are valid
  # Uses section A by default.
  def add_course(section_id)
    self.courses.create(:section_id => section_id)
  end

  # Changes section for some course on the schedule.
  def switch_section(course_id, section_id)
    # FIXME
    # self.courses.find_by_course_id(course_id)
    #            .update_attribute(:section_id, section_id)
    #            .save
  end

  # Deletes a course from the schedule.
  def delete_course(course_id)
    # FIXME
    # self.courses.find_by_course_id(course_id).destroy!
  end

end
