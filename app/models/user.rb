require 'open-uri'

class User < ActiveRecord::Base
  has_many :user_to_courses
  has_many :courses, :through => :user_to_courses
  
  def self.create_with_omniauth(auth)
    create! do |user|
      user.uid = auth["uid"]
      user.name = auth["user_info"]["name"]
    end
  end
  
  def self.find_by_uid(uid)
    find(uid) rescue nil
  end
  
  def get_scheduleman_data
    data = open('https://scheduleman.org/schedules/sqGWsIDrvN.ics') {|f| f.read}
  end
end
