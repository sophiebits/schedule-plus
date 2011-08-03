# require 'openssl'
# require 'hpricot'
# require 'open-uri'
# OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
# 
# def isempty(cell)
#   cell.to_s.strip == "<td>&nbsp;</td>"
# end
# 
# doc = open('https://enr-apps.as.cmu.edu/assets/SOC/sched_layout_fall.htm') { |f| Hpricot(f) }
# table = doc.search("//table")
# rows = (table/"tr")
# 
# (0...rows.length).to_a.each do |i|
#   cells = (rows[i]/"td")
#   prev_cells = (rows[i-1]/"td") if i > 0
#   prev_prev_cells = (rows[i-2]/"td") if i > 1
# 
#   if ( cells[1] && !isempty(cells[1]) && isempty(cells[2]) && isempty(cells[0]) &&
#     prev_cells &&  prev_cells[1] && !isempty(prev_cells[1]) && isempty(prev_cells[2]) && isempty(prev_cells[3]) &&
#     prev_prev_cells &&  prev_prev_cells[1] && !isempty(prev_prev_cells[1]) && isempty(prev_prev_cells[2]) && isempty(prev_prev_cells[3]))
#     puts "------------"
#     puts "cells[0]"+cells[0].to_s
#     puts prev_prev_cells[1]
#     puts prev_cells[1]
#     puts cells[1]
#   end
#   # number = cells[0].inner_text if cells[0]
#   # name = cells[1].inner_text if cells[1]
#   # units = cells[2].inner_text if cells[2]
#   # section = cells[3].inner_text if cells[3]
#   # 
#   # 
#   # puts cells[1].inner_text if cells[1]
#   
# end

user1 = User.create(:uid => "1326120295", :name => "Eric Wu")
user2 = User.create(:uid => "1326120240", :name => "Jen")
vincent = User.create(:uid => "9999", :name => "Vincent Siao")

c15210 = Course.create(:number => '15-210', :name => 'Parallel and Sequential Data Structures and Algorithms', :has_recitation => true)
l152101 = Lecture.create(:section => '1', :course_id => c15210.id)
LectureSectionTime.create(:day => 'tuesday', :location => 'BH 136A', :begin => '630', :end => '720', :lecture_id => l152101.id)
LectureSectionTime.create(:day => 'thursday', :location => 'BH 136A', :begin => '630', :end => '720', :lecture_id => l152101.id)
r15210D = Recitation.create(:section => 'D', :lecture_id => l152101.id)
RecitationSectionTime.create(:day => 'wednesday', :location => 'DH 1211', :begin => '810', :end => '870', :recitation_id => r15210D.id)
sc15210D = ScheduledCourse.create(:course_id => c15210.id, :lecture_id => l152101.id, :recitation_id => r15210D.id)

c15396 = Course.create(:number => '15-396', :name => 'Special Topic: Science of the Web', :has_recitation => false)
l15396A = Lecture.create(:section => 'A', :course_id => c15396.id)
LectureSectionTime.create(:day => 'tuesday', :location => 'HBH 1000', :begin => '900', :end => '990', :lecture_id => l15396A.id)
LectureSectionTime.create(:day => 'thursday', :location => 'HBH 1000', :begin => '900', :end => '990', :lecture_id => l15396A.id)
sc15396A = ScheduledCourse.create(:course_id => c15396.id, :lecture_id => l15396A.id)

Schedule.create(:scheduled_course_id => sc15210D.id, :user_id => vincent.id)
Schedule.create(:scheduled_course_id => sc15396A.id, :user_id => vincent.id)
