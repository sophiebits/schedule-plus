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

  def last_name
    if name then
      name.split(" ").last
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
    fids = Rails.cache.fetch('fids' + uid.to_s) do
      return [] if !fb
      fb.friends.map(&:identifier)
    end
    @friends ||= User.where(:uid => fids).all
  end

###############################################################################

  def friends_with?(user)
    self.friends.include? user
  end

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
    
    cs = self.main_schedule.course_selections

    course_selection_section = cs.includes(
      :section => [:scheduled_times]).where('scheduled_times.days ' + Rails.application.config.like_operator + ' ?',
      "%#{current_day}%").where('scheduled_times.begin <= ? AND scheduled_times.end >= ?', current_time_in_min, current_time_in_min).first
    course_selection_lecture = cs.includes(
      :section => [:lecture => :scheduled_times]).where('scheduled_times.days ' + Rails.application.config.like_operator + ' ?',
      "%#{current_day}%").where('scheduled_times.begin <= ? AND scheduled_times.end >= ?', current_time_in_min, current_time_in_min).first
      
    number = ''
    section = ''

    if course_selection_section
      number = course_selection_section.section.course.number
      section = course_selection_section.section.letter
    elsif course_selection_lecture
      number = course_selection_lecture.section.course.number
      section = 'Lec' + course_selection_lecture.section.lecture.number.to_s
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
