# Semester is Fall 2011

class OldBase < ActiveRecord::Base
  self.abstract_class = true
  establish_connection "old"
end

class OldUser < OldBase
  set_table_name 'users'

  has_many :schedules,
           :class_name => "OldSchedule",
           :foreign_key => "user_id"

  def to_model
    User.new do |u|
      u.name = self.name
      u.uid = self.uid
    end
  end
end

class OldSchedule < OldBase
  set_table_name 'schedules'
  
  belongs_to :user,
             :class_name => "OldUser"
  has_many :course_selections,
           :class_name => "OldCourseSelection",
           :foreign_key => "schedule_id"

  def to_model
    Schedule.new do |s|
      s.user_id = self.user_id
      s.semester_id = Semester.find_by_name("Fall 2011")
      s.active = false
    end
  end
end

class OldCourse < OldBase
  set_table_name 'courses'

  has_many :scheduled_courses,
           :class_name => "OldScheduledCourse",
           :foreign_key => "course_id"
end

class OldLecture < OldBase
  set_table_name 'lectures'

  has_many :scheduled_courses,
           :class_name => "OldScheduledCourse",
           :foreign_key => "lecture_id"
end

class OldRecitation < OldBase
  set_table_name 'recitations'

  has_many :scheduled_courses,
           :class_name => "OldScheduledCourse",
           :foreign_key => "recitation_id"
end

class OldScheduledCourse < OldBase
  set_table_name 'scheduled_courses'

  has_many :course_selections,
           :class_name => "OldCourseSelection"
  belongs_to :course,
             :class_name => "OldCourse"
  belongs_to :lecture,
             :class_name => "OldLecture"
  belongs_to :recitation,
             :class_name => "OldRecitation"
end

class OldCourseSelection < OldBase
  set_table_name 'course_selections'

  belongs_to :schedule,
             :class_name => "OldSchedule"
  belongs_to :scheduled_course,
             :class_name => "OldScheduledCourse"

  def to_model
    course = Course.find_by_number(self.scheduled_course.course.number)
    if course.nil?
      p "Error: Course Not Found (" + self.scheduled_course.course.number + ")"
      return nil
    end
    letter = self.scheduled_course.recitation.try(:section) ||
             self.scheduled_course.lecture.try(:section)
    section = course.find_by_section(letter) if letter
    CourseSelection.new do |cs|
      cs.schedule_id = self.schedule_id
      cs.section_id = section.try(:id) || course.sections.first.try(:id)
    end
  end
end

class Importer < ActiveRecord::Base
  self.abstract_class = true
  
  def self.import_all
    OldUser.all.each do |u|
      p u.name
      u.schedules.each_with_index do |s,i|
        print " Schedule " + (i+1).to_s + ": "
        p s.course_selections.map {|cs| 
            model = cs.to_model if cs.scheduled_course
            model.course.number.to_s if model
          }.select {|n| !n.nil? }.join ", "
      end
    end
  end
end
