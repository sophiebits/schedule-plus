class User < ActiveRecord::Base
  def self.create_with_omniauth(auth)
    create! do |user|
      user.uid = auth["uid"]
      user.name = auth["user_info"]["name"]
    end
  end
  
  def self.find_by_uid(uid)
    find(ui) rescue nil
  end
end
