class Course < ActiveRecord::Base
  has_many :lectures
  has_many :recitations, :through => :lectures
  has_many :scheduled_courses

  def find_by_section(letter)
    if lectures.find_by_section(letter)
      lectures.find_by_section(letter)
    else
      recitations.find_by_section(letter)
    end
  end
end
