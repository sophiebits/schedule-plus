class Course < ActiveRecord::Base
  has_many :lectures
  has_many :recitations, :through => :lectures
  has_many :scheduled_courses

  def as_json(options={})
    {
      :id => self.id,
      :number => self.number,
      :name => self.name
    }
  end

  def find_by_section(letter)
    if lectures.find_by_section(letter)
      lectures.find_by_section(letter)
    else
      recitations.find_by_section(letter)
    end
  end
end
