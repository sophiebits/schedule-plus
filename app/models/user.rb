class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable 
  devise :database_authenticatable, :registerable, #:omniauthable,
         :recoverable, :rememberable, :trackable#, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me
  
  # omniauth
  has_many :authentications
  has_many :schedules

  def main_schedule(semester=Semester.current)
    schedules.active.by_semester(semester).first
  end

############################# AUTHENTICATION ####################################

  def apply_omniauth(omniauth)
    #self.email = omniauth['user_info']['email'] if email.blank?
    case omniauth['provider']
    when 'facebook'
      self.apply_facebook(omniauth)
    end
    authentications.build(:provider => omniauth['provider'], 
                          :uid => omniauth['uid'],
                          :token => (omniauth['credentials']['token'] rescue nil))
  end

  # fb_graph for a user
  def fb
    @fb_user ||= FbGraph::User.me(self.authentications.find_by_provider('facebook').token)
                              .fetch
  end

  def password_required?
    (authentications.empty? || !password.blank?) && super
  end

###############################################################################

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
    current_day = %w(U M T W R F S)[current_time.wday]

    course_selections = self.main_schedule.course_selections.includes(
      :section => [[:lecture => :scheduled_times], 
      :scheduled_times])

    current_course_selection = course_selections.where(
      'scheduled_times.begin <= ? AND scheduled_times.end >= ? AND scheduled_times.days LIKE ?',
      current_time_in_min, current_time_in_min, "%#{current_day}%").first

    number = ''
    section = ''

    if current_course_selection
      number = current_course_selection.section.course.number
      section = current_course_selection.section.letter
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

  protected

  def apply_facebook(omniauth)
    if (extra = omniauth['extra']['user_hash'] rescue false)
      self.email = (extra['email'] rescue '')
    end
  end
end
