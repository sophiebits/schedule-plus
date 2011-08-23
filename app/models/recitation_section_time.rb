class RecitationSectionTime < ActiveRecord::Base
  belongs_to :recitation

  def as_json(options={})
    {
      :day => self.day,
      :begin => self.begin,
      :end => self.end,
      :location => self.location
    }
  end
end
