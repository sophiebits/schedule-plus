class Recitation < ActiveRecord::Base
  belongs_to :lecture
  has_one :scheduled_course
  has_many :recitation_section_times
end
