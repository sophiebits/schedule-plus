# Semester is Fall 2011

class Legacy::Base < ActiveRecord::Base
  # self.abstract_class = true
  establish_connection "old"
end

class Legacy::User < Legacy::Base
  set_table_name 'users'

  has_many :schedules,
           :class_name => "Legacy::Schedule"

  def to_model
    User.new do |u|
      u.name = self.name
      u.uid = self.uid
    end
  end
end

class Legacy::Schedule < Legacy::Base
  set_table_name 'schedules'
  
  belongs_to :user,
             :class_name => "Legacy::User"
  has_many :course_selections,
           :class_name => "Legacy::CourseSelection"

  def to_model
    Schedule.new do |s|
      s.user_id = self.user_id
      s.semester_id = Semester.find_by_name("Fall 2011")
      s.active = false
    end
  end
end

class Legacy::CourseSelection < Legacy::Base
  set_table_name 'course_selections'

  belongs_to :schedule,
             :course_name => "Legacy::Schedule"

  def to_model
    CourseSelection.new do |cs|
      cs.schedule_id = self.schedule_id
      cs.section_id = nil #??????
    end
  end
end

class Legacy::Importer < Legacy::Base
  def import_all
    false
  end
end
