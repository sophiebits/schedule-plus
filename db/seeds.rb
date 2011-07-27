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

user1 = User.create(:uid => "1234", :name => "Bob")
user2 = User.create(:uid => "5678", :name => "Sally")

course1 = Course.create(:course_number => "15213", :section => "A", :name => "Intro to Computer Systems")
course2 = Course.create(:course_number => "15212", :section => "C", :name => "Principle of Prog")
course3 = Course.create(:course_number => "15212", :section => "D", :name => "Principle of Prog")

user1.courses = [course1, course2]
user2.courses = [course2, course3]
