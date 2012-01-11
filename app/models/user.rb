class User < ActiveRecord::Base
  # omniauth
  has_many :authentications, :dependent => :destroy
  has_many :schedules, :order => "semester_id desc, id asc", :dependent => :destroy

  def first_name
    if name then
      name.split(" ").first
    else
      ""
    end
  end

  def main_schedule(semester=Semester.current)
    schedules.primary.by_semester(semester).all.first
  end

  def active?(semester=Semester.current)
    !main_schedule(semester).nil?
  end

  def courses(semester=Semester.current)
    main_schedule(semester).course_selections.map(&:course)
  end

############################# AUTHENTICATION ####################################

  def apply_omniauth(omniauth)
    self.name = omniauth['user_info']['name'] if name.blank?
    self.uid = omniauth['uid']
    authentications.build(:provider => omniauth['provider'], 
                          :uid => omniauth['uid'],
                          :token => (omniauth['credentials']['token'] rescue nil))
  end

  def fb_uid
    self.authentications.find_by_provider('facebook').token rescue nil
  end
  
  # fb_graph for a user
  def fb
    @fb_user ||= FbGraph::User.me(fb_uid).fetch
  end

  def friends
    Rails.cache.fetch('friends' + uid.to_s + 'all') do
      return [] if !fb
      fids = fb.friends.map(&:identifier)
      User.where(:uid => fids).all
    end
  end

###############################################################################

  # true if user is in the course
  def in_course?(course)
    main_schedule.course_selections.map(&:course).each do |my_course|
      return true if my_course == course
    end
    false
  end

  # the current status of the user, e.g. "free" or "in XX-XXX"
  # TODO cache this
  def status
    return '' if !self.main_schedule

    current_time = Time.now.in_time_zone
    current_time_in_min = current_time.hour*60 + current_time.min
    current_day = %w(U M T W R F S)[current_time.wday]

    course_selections = self.main_schedule.course_selections.includes(
      :section => [:scheduled_times, :lecture => :scheduled_times]).where('scheduled_times.days ' + Rails.application.config.like_operator + ' ?',
      "%#{current_day}%")

    current_course_selection = course_selections.where(
      'scheduled_times.begin <= ? AND scheduled_times.end >= ?',
      current_time_in_min, current_time_in_min).first

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

end
