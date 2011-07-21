class Student < ActiveRecord::Base
  attr_accessible :name, :scheduleman_url
  
  belongs_to :schedule

end
