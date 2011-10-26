class Schedule < ActiveRecord::Base
  belongs_to :user
  has_many :courses, :class_name => 'CourseSelection'
  scope :active, :conditions => { :active => true }
  
  def after_initialize
    if new_record?
      hash_len = 4
      charset = ('a'..'z').to_a + ('A'..'Z').to_a + (0..9).to_a
      begin
        hash = (0...hash_len).map{charset.to_a[rand(charset.size)]}.join
        hash_len += 1
      end while !Schedule.find_by_hash(hash).blank?
      self.hash = hash
    end
  end
 
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
    course_id = Section.find(section_id).course_id
    i = courses.map{|cs| cs.course.id}.index(course_id)
    if i.nil? 
      courses.create(:section_id => section_id)
    else
      courses[i].update_attribute(:section_id, section_id)
    end
  end

  # returns true is st1 and st2 overlap in time
  def has_overlap?(st1, st2)
    (st1.begin <= st2.end) && (st2.begin <= st1.end)
  end
  
  # returns true if schedule has time conflicts
  def has_conflicts?
    # get list of all scheduled times in this schedule
    scheduled_times = self.courses.collect{
      |s| s.section.lecture ? [s.section.times, s.section.lecture.times] : s.section.times}.flatten
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

end
