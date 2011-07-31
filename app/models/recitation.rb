class Recitation < ActiveRecord::Base
  belongs_to :lecture
  has_many :recitation_section_times
end
