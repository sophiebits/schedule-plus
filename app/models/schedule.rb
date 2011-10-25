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

  # Adds a course by course_id and section_id.
  # Assumes course_id and section_id are valid
  # Uses section A by default.
  def add_course(course_id, section_id)
    section_id ||= Course.find(course_id).find_by_section('A')
    self.courses.create(:course_id => course_id,
                        :section_id => section_id)
  end

  # Changes section for some course on the schedule.
  def switch_section(course_id, section_id)
    self.courses.find_by_course_id(course_id)
                .update_attribute(:section_id, section_id)
                .save
  end

  # Deletes a course from the schedule.
  def delete_course(course_id)
    self.courses.find_by_course_id(course_id).destroy!
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
