require 'rubygems'
require 'hpricot'
require 'openssl'
require 'open-uri'

OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

def isempty(cell)
	str = cell.inner_text.strip
	return true if !str
	
	if str.length == 1
		match = str[/[[:alnum:]]+/]
		return true if !match
		return match.length == 0
	end
	
	return ((str == "&nbsp;") || (str == ""))
end

def isemptystr(str)
	str = str.strip
	return true if !str
	
	if str.length == 1
		match = str[/[[:alnum:]]+/]
		return true if !match
		return match.length == 0
	end
	
	return ((str == "&nbsp;") || (str == ""))
end

def getsection(sec)
	if sec.include? 'Lec'
		if sec == 'Lec'
			return '1'
		end
		return sec[-1,1]
	end
	sec
end

def islecture(sec)
	sec.include? 'Lec'
end

def getday(c)
	case c
	when 'M'
		return 'Monday'
	when 'T'
		return 'Tuesday'
	when 'W'
		return 'Wednesday'
	when 'R'
		return 'Thursday'
	when 'F'
		return 'Friday'
	when 'U'
		return 'Sunday'
	when 'S'
		return 'Saturday'
	end
end

def getdays(days)
	abort "Days was nil or empty" if !days || (days == '') || (isemptystr(days))
	return ['TBA'] if (days == 'TBA')
	
	days_arr = []
	days.each_char do |c|
		days_arr.push getday(c)
	end
	days_arr
end

########################################################
# Debugging ############################################
########################################################
def Coursecreate(map)
	puts "+============================= COURSE =======================================+"
	puts 'num:   ' + map[:number]
	puts 'name:  ' + map[:name]
	puts 'units: ' + map[:units]
	1
end

def Lecturecreate(map)
	puts "    -------- LECTURE --------"
	puts '    section:   ' + map[:section]
	puts '    instrctr:  ' + map[:instructor]
	1
end

def LectureSectionTimecreate(map)
		puts "        ___ LEC SEC TIME ___"
		puts '        day:   ' + map[:day]
		puts '        begin: ' + map[:begin]
		puts '        end:   ' + map[:end]
		puts '        loc:   ' + map[:location]
		1
end

def Recitationcreate(map)
		puts "        ---- RECITATION ----"
		puts '        section:   ' + map[:section]
		1
end

def RecitationSectionTimecreate(map)
		puts "            ___ REC SEC TIME ___"
		puts '            day:   ' + map[:day]
		puts '            begin: ' + map[:begin]
		puts '            end:   ' + map[:end]
		puts '            loc:   ' + map[:location]
		1
end
##########################################################
##########################################################
##########################################################

def timetostring(time)
	return 'TBA' if (!time) || (time == 'TBA') || (time == '') || (isemptystr(time))
	
	is_pm = (((time.include? 'PM') && !(time.include? '12:')) || (!(time.include? 'PM') && (time.include? '12:')))
	times = time[0,5].split(':')
	hour = times[0]
	min = times[1]
	if is_pm
		hour = (hour.to_i + 12).to_s
	end

	hour + min
end



######################
file = 'https://enr-apps.as.cmu.edu/assets/SOC/sched_layout_fall.htm'
#file = 'scheduleman_small.html'

parse_file = File.new("_parse_file.html", "w")
file = open(file)

File.readlines(file).each do |line|
	if line.include? 'Lec/Sec'
		open(parse_file, 'a') { |f| f.puts '<TABLE>' }
	elsif line.include? '<B>'
		open(parse_file, 'a') { |f| f.puts '<TR>' }
	else
		open(parse_file, 'a') { |f| f.puts line }
	end
end


doc = open(parse_file) { |f| Hpricot(f) }
table = doc.search("//table")
rows = (table/"tr")

######################

catch(:done) do
	i = 0
	while i < rows.length
	
		cells = (rows[i]/"td")
	
		# if 'Title' is empty, it is a category, not a course
		if (!isempty(cells[0]) && isempty(cells[1])) || (cells[0].inner_text == 'Course') || (isempty(cells[0]))
			puts '*** SKIPPING ***' + cells.to_s
			i += 1
			next
		end

		throw :done if i >= rows.length
	
		abort 'Error (1)' if isempty(cells[0]) || isempty(cells[1]) || isempty(cells[2])
		# Create Course
		db_course = Course.create(:number => cells[0].inner_text,
															:name		=> cells[1].inner_text,
															:units	=> cells[2].inner_text)

		# Loop through Course info, creating lectures/recitations, etc.
		begin
			# If course name is long and takes two vertical rows, move on to next row
			if isempty(cells[3]) && isempty(cells[4])
				i += 1
				throw :done if i >= rows.length
				cells = (rows[i]/"td")
			end
		
			# Create Lecture	
			section = cells[3].inner_text
			db_lecture = Lecture.create(:course_id	=> db_course.id,
																	:section		=> getsection(section),
																	:instructor => cells[8].inner_text)
	
			# Create all the Lecture Section Times, attaching them to Lecture
			db_lec_sec_time = nil
			begin
				getdays(cells[4].inner_text).each do |day|
					db_lec_sec_time = LectureSectionTime.create(:lecture_id => db_lecture.id,
																											:day 				=> day,
																											:begin 			=> timetostring(cells[5].inner_text),
																											:end 				=> timetostring(cells[6].inner_text),
																											:location 	=> cells[7].inner_text)
				end
				i += 1
				throw :done if i >= rows.length
				cells = (rows[i]/"td")
			end while isempty(cells[3]) && isempty(cells[0]) && isempty(cells[1])
	
			abort 'Lecture section time was nil!' if !db_lec_sec_time
	
			# Check if lecture section is 'Lec' and contains recitations under it
			if islecture(section)
				# Loop through course sections that take multiple rows
				while i < rows.length
					cells = (rows[i]/"td")
					if !isempty(cells[0]) || islecture(cells[3].inner_text)
						break
					end
			
					# If course name is long and takes two vertical rows, move on to next row
					if isempty(cells[3]) && isempty(cells[4])
						i += 1
						throw :done if i >= rows.length
						cells = (rows[i]/"td")
					end
			
					# Create Recitation
					db_recitation = Recitation.create(:lecture_id	=> db_lecture.id,
																						:section 		=> getsection(cells[3].inner_text),
																						:instructor => cells[8].inner_text)
		
					db_rec_sec_time = nil
					# Create all Recitation Section Times, attatching them to Recitation
					begin
						getdays(cells[4].inner_text).each do |day|
							db_rec_sec_time = RecitationSectionTime.create(	:recitation_id => db_recitation.id,
																															:day 				=> day,
																															:begin 			=> timetostring(cells[5].inner_text),
																															:end 				=> timetostring(cells[6].inner_text),
																															:location 	=> cells[7].inner_text)
						end
						i += 1
						throw :done if i >= rows.length
						cells = (rows[i]/"td")
					end while isempty(cells[3]) && isempty(cells[0]) && isempty(cells[1])
				
					abort 'Recitation section time was nil!' if !db_rec_sec_time
				
				end
			end
		end while isempty(cells[0])
	
	end
end
###############
### Old way: ##
###############
# c15210 = Course.create(:number => '15-210', :name => 'Parallel and Sequential Data Structures and Algorithms', :has_recitation => true)
# l152101 = Lecture.create(:section => '1', :course_id => c15210.id)
# LectureSectionTime.create(:day => 'tuesday', :location => 'BH 136A', :begin => '630', :end => '720', :lecture_id => l152101.id)
# LectureSectionTime.create(:day => 'thursday', :location => 'BH 136A', :begin => '630', :end => '720', :lecture_id => l152101.id)
# r15210D = Recitation.create(:section => 'D', :lecture_id => l152101.id)
# RecitationSectionTime.create(:day => 'wednesday', :location => 'DH 1211', :begin => '810', :end => '870', :recitation_id => r15210D.id)
# sc15210D = ScheduledCourse.create(:course_id => c15210.id, :lecture_id => l152101.id, :recitation_id => r15210D.id)
# 
# c15213 = Course.create(:number => '15-213', :name => 'Introduction to Computer Systems', :has_recitation => true)
# l152131 = Lecture.create(:section => '1', :course_id => c15213.id)
# LectureSectionTime.create(:day => 'tuesday', :location => 'DH 2315', :begin => '810', :end => '900', :lecture_id => l152131.id)
# LectureSectionTime.create(:day => 'thursday', :location => 'DH 2315', :begin => '810', :end => '900', :lecture_id => l152131.id)
# r15213F = Recitation.create(:section => 'F', :lecture_id => l152131.id)
# RecitationSectionTime.create(:day => 'monday', :location => 'DH 1211', :begin => '810', :end => '870', :recitation_id => r15213F.id)
# sc15213F = ScheduledCourse.create(:course_id => c15213.id, :lecture_id => l152131.id, :recitation_id => r15213F.id)
# 
# c15396 = Course.create(:number => '15-396', :name => 'Special Topic: Science of the Web', :has_recitation => false)
# l15396A = Lecture.create(:section => 'A', :course_id => c15396.id)
# LectureSectionTime.create(:day => 'tuesday', :location => 'HBH 1000', :begin => '900', :end => '990', :lecture_id => l15396A.id)
# LectureSectionTime.create(:day => 'thursday', :location => 'HBH 1000', :begin => '900', :end => '990', :lecture_id => l15396A.id)
# sc15396A = ScheduledCourse.create(:course_id => c15396.id, :lecture_id => l15396A.id)
# 
# c21301 = Course.create(:number => '21-301', :name => 'Combinatorics', :has_recitation => false)
# l21301A = Lecture.create(:section => 'A', :course_id => c21301.id)
# LectureSectionTime.create(:day => 'monday', :location => 'BH A51', :begin => '750', :end => '810', :lecture_id => l21301A.id)
# LectureSectionTime.create(:day => 'wednesday', :location => 'BH A51', :begin => '750', :end => '810', :lecture_id => l21301A.id)
# LectureSectionTime.create(:day => 'friday', :location => 'BH A51', :begin => '750', :end => '810', :lecture_id => l21301A.id)
# sc21301A = ScheduledCourse.create(:course_id => c21301.id, :lecture_id => l21301A.id)
# 
# Schedule.create(:scheduled_course_id => sc15210D.id, :user_id => vincent.id)
# Schedule.create(:scheduled_course_id => sc15213F.id, :user_id => vincent.id)
# Schedule.create(:scheduled_course_id => sc15396A.id, :user_id => vincent.id)
# Schedule.create(:scheduled_course_id => sc21301A.id, :user_id => vincent.id)
#################

user1 = User.create(:uid => "1326120295", :name => "Eric Wu")
user2 = User.create(:uid => "1326120240", :name => "Jen")
vincent = User.create(:uid => "9999", :name => "Vincent Siao")


c15210 = Course.find_by_number("15210")
c15213 = Course.find_by_number("15213")
c15396 = Course.find_by_number("15396")
c21301 = Course.find_by_number("21301")

l15210 = Lecture.find_by_course_id_and_section(c15210.id, '1')
r15210 = Recitation.find_by_lecture_id_and_section(l15210.id, 'D')
sc15210 = ScheduledCourse.create(:course_id => c15210.id, 
																	:lecture_id => l15210.id,
																	:recitation_id => r15210.id)

l15213 = Lecture.find_by_course_id_and_section(c15213.id, '1')
r15213 = Recitation.find_by_lecture_id_and_section(l15213.id, 'F')
sc15213 = ScheduledCourse.create(:course_id => c15213.id, 
																	:lecture_id => l15213.id,
																	:recitation_id => r15213.id)																

l15396 = Lecture.find_by_course_id_and_section(c15396.id, 'A')
sc15396 = ScheduledCourse.create(:course_id => c15396.id, 
																	:lecture_id => l15396.id)														

l21301 = Lecture.find_by_course_id_and_section(c21301.id, 'A')
sc21301 = ScheduledCourse.create(:course_id => c21301.id, 
																	:lecture_id => l21301.id)																


Schedule.create(:scheduled_course_id => sc15210.id, :user_id => vincent.id)
Schedule.create(:scheduled_course_id => sc15213.id, :user_id => vincent.id)
Schedule.create(:scheduled_course_id => sc15396.id, :user_id => vincent.id)
Schedule.create(:scheduled_course_id => sc21301.id, :user_id => vincent.id)
