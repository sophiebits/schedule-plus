require 'open-uri'

class User < ActiveRecord::Base
  has_many :schedules
  has_many :scheduled_courses, :through => :schedules
  
  def self.create_with_omniauth(auth)
    create! do |user|
      user.uid = auth["uid"]
      user.name = auth["user_info"]["name"]
    end
  end
  
  def get_scheduleman_data
    data = open('https://scheduleman.org/schedules/sqGWsIDrvN.ics') {|f| f.read}
  end
end
