class Schedule < ActiveRecord::Base
  belongs_to :user
  belongs_to :semester
  has_many :course_selections, :class_name => 'CourseSelection', :dependent => :destroy
  scope :primary, :conditions => { :primary => true }
  scope :by_semester, lambda {|sem| where(:semester_id => sem.id)}

  before_create :generate_url, :generate_name

  def as_json(options={})
    {
      :id      => self.id,
      :user    => self.user,
      :course_selections => self.course_selections,
      :primary  => self.primary
    }
  end

  def to_param
    url
  end

  def units
    units_lower = 0
    units_upper = 0
    self.course_selections.each do |cs|
      units = cs.course.units.split('-')
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
  
  def rename(new_name)
    #validated the schedule names
    if (!new_name.empty? and new_name.length < 25)
      update_attribute(:name, new_name)
    end
  end

  def make_primary!
    # make all other semester schedules secondary
    user.schedules.by_semester(semester).each do |s|
      s.update_attribute(:primary, false)
    end
    update_attribute(:primary, true)
    true
  end

  def copy!(schedule)
    update_attribute(:semester, schedule.semester)
    update_attribute(:primary, false)
    course_selections.map(&:destroy)
    schedule.course_selections.each {|selection|
      course_selections.create(:section => selection.section)
    }
  end

  def courses
    course_selections.map(&:course)
  end

  # Adds a course by section_id; assumes section_id is valid.
  def add_course(section_id)
    course_id = Section.find(section_id).course_id
    if courses.include? Course.find(course_id)
      switch_section(section_id)
      return nil
    end
    course_selections.create(:section_id => section_id)
  end

  def switch_section(section_id)
    course_id = Section.find(section_id).course_id
    i = course_selections.map {|cs| cs.course.id }.index(course_id)
    course_selections[i].update_attributes(:section_id => section_id)
    course_selections[i].reload()
  end
  
  def empty?
    course_selections.count.zero?
  end

  # returns true is st1 and st2 overlap in time
  def has_overlap?(st1, st2)
    (st1.begin <= st2.end) && (st2.begin <= st1.end)
  end
  
  # returns true if schedule has time conflicts
  def has_conflicts?
    # get list of all scheduled times in this schedule
    scheduled_times = self.course_selections.collect{
      |s| s.section.lecture ? [s.section.scheduled_times, s.section.lecture.scheduled_times] : s.section.scheduled_times}.flatten
    "UMTWRFS".split('').each do |day|
      day_scheduled_times = scheduled_times.find_all{|st| st.days.include? day}
      # generate all unique pairs of scheduled times
      st_pairs = day_scheduled_times.combination(2).to_a
      st_pairs.each do |p|
        return true if has_overlap?(p[0], p[1])
      end
    end
    false
  end
  
  def create_permutations
    
  end
  
  private
  
  def generate_url
    if new_record?
      url_len = 5
      charset = ('a'..'z').to_a + ('A'..'Z').to_a + (0..9).to_a
      begin
        url = (0...url_len).map{charset.to_a[rand(charset.size)]}.join
        url_len += 1
      end while !Schedule.find_by_url(url).blank?
      self.url = url
    end
  end
  
  def generate_name
    if user.nil?
      self.name = 'New Schedule'
    else
      self.name = 'Schedule ' + (user.schedules.count + 1).to_s
    end
  end
  
end
