class LectureSectionTime < ActiveRecord::Base
  belongs_to :lecture

  def as_json(options={})
    {
      :day => self.day,
      :begin => self.begin,
      :end => self.end,
      :location => self.location
    }
  end
end
