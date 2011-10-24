class User < ActiveRecord::Base
  has_many :schedules

  DAY_NAME = %w(Sunday Monday Tuesday Wednesday Thursday Friday Saturday)

  def main_schedule(semester)
    schedules.where(:active => true, :semester => semester)
  end

  def self.create_with_omniauth(auth)
    create! do |user|
      user.uid = auth["uid"]
      user.name = auth["user_info"]["name"]
    end
  end

  def as_json(options={})
    {
      :id => self.id,
      :uid => self.uid,
      :name => self.name,
      :status => self.status
    }
  end

  # true if user is in the course
  def in_course?(course)
    main_schedule.course_selections.map(&:course).each do |my_course|
      return true if my_course == course
    end
    false
  end

  # array of courses in common with friend
  def courses_in_common(friend)
    user_courses = self.main_schedule.scheduled_courses.collect{|sc| sc.course}
    friend_courses = friend.main_schedule.scheduled_courses.collect{|sc| sc.course}

    # intersection of user_courses and friend_courses
    user_courses & friend_courses
  end

  # the current status of the user, e.g. "free" or "in XX-XXX"
  def status
    return '' if !self.main_schedule

    current_time = Time.now.in_time_zone
    current_time_in_min = current_time.hour*60 + current_time.min
    current_time_in_min = 750
    current_day = DAY_NAME[current_time.wday]

    course_selections = self.main_schedule.course_selections.includes(
      :lecture => :scheduled_times,
      :recitation => :scheduled_times,
      :course => [])

    current_course_selections = course_selections.where('scheduled_times.begin <= ? AND scheduled_times.end >= ? AND scheduled_times.day = ?',
      current_time_in_min, current_time_in_min, current_day)

    number = ''
    section = ''

    if current_course_selections.length > 0
      number = current_course_selections[0].section.course.number
      section = current_course_selections[0].section.letter
    end

    if number == ''
      return 'free'
    else
      return 'in ' + number + ' ' + section
    end
  end

  def free?
    self.status == 'free'
  end

  def update_active_schedule(schedule)
    if (schedule.user == self)
      active_schedules.find_by_semester(schedule.semester)
                      .update_attribute(:active,false)
                      .save
      schedule.update_attribute(:active,true).save
    end
  end
end
