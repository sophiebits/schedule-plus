class ScheduledTime < ActiveRecord::Base
  belongs_to :schedulable, :polymorphic => true

  def to_str
    if self.begin == -1 || self.end == -1
      return ""
    end
    begin_time = Time.mktime(0) + self.begin * 60
    end_time = Time.mktime(0) + self.end * 60
    begin_time.strftime("%l:%M%P") + "-" + end_time.strftime("%l:%M%P").strip
  end
end
