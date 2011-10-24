require 'rubygems'
require 'hpricot'
require 'openssl'
require 'open-uri'

OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

#############
# Semesters #
#############

if Semester.all.count == 0
  Semester.create(:name => "Fall 2010", :current => true)
  Semester.create(:name => "Spring 2011", :current => false)
end
#############

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

########################################################
# Debugging ############################################
########################################################
def Course_create(map)
	puts "+============================= COURSE =======================================+"
	puts 'num:   ' + map[:number].to_s
	puts 'name:  ' + map[:name]
	puts 'units: ' + map[:units]
	1
end

def Lecture_create(map)
	puts "    -------- LECTURE --------"
	puts '    section:   ' + map[:number].to_s
#	puts '    instrctr:  ' + map[:instructor]
	1
end

def ScheduledTime_create(map)
		puts "        ___ SCHED SEC TIME ___"
		puts '        day:   ' + map[:day]
		puts '        begin: ' + map[:begin].to_s
		puts '        end:   ' + map[:end].to_s
		puts '        loc:   ' + map[:location]
		1
end

def Section_create(map)
		puts "        ---- SECTION ----"
		puts '        section:   ' + map[:letter]
		1
end

##########################################################
##########################################################
##########################################################

def validatedays(days)
  if days == "TBA" || (days == "&nbsp;")
    return ""
  end
  days
end

def timetominutes(time)     
return -1 if !time || time == ''

is_pm = (time.include? 'PM')
times = time[0,5].split(':')
hour = times[0]
min = times[1]

if (hour.include? "12")
	hour = (hour.to_i - 12)
end

if is_pm
	hour = (hour.to_i + 12)
end

(hour.to_i*60 + min.to_i)
end

def reformatunits(units)
  units.gsub!(',', '-')
  split = units.split('-')
  if split[0] == split[-1]
    units = split[0].to_f.to_s
  else
    first = split[0].to_f
    second = split[-1].to_f
    units = first.to_s + '-' + second.to_s
  end

  units
end

# If begin_time > end_time, SoC fucked up, so we fix it for them
def validatetimes(begin_time, end_time)
  if (begin_time > end_time)
    if (begin_time >= 720 && end_time >= 720)
      begin_time -= 720
    else
      end_time += 720
    end
  end
  
  return [begin_time, end_time]
end

def check_sections_offered(offered_sections, db_sections)
	# check if any sections are not in offered_sections, i.e. they are no longer offered
	db_sections.each do |sec|
	  if !offered_sections.include?(sec.letter)
	    # section not found anymore, mark it not offered!
	    sec.update_attribute(:offered, false)
	    sec.save!
	  end
	end
end

######################
#file = 'https://enr-apps.as.cmu.edu/assets/SOC/sched_layout_fall.htm'
file = 'scheduleman_small.html'

if Rails.env.production?
	parse_file = File.new("#{RAILS_ROOT}/tmp/parse_file_#{Process.pid}.html", "w")
else
	parse_file = File.new("parse_file.html", "w")
end
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

offered_courses = []

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
    
    # Prints name and number so that I know something's happening
    puts cells[0].inner_text + ' ' + cells[1].inner_text
		
		number = cells[0].inner_text
		number.insert(2, '-')
		
		name = cells[1].inner_text
		units = reformatunits(cells[2].inner_text)
		
		db_course = Course.find_by_semester_id_and_number(Semester.current.id, number)
		if db_course
		  db_course.update_attributes(Hash[:name => name, :units => units, :offered => true])
		  db_course.save!
		else
      # Create Course
  		db_course = Course.create(:number => number,
  															:name		=> name,
  															:units	=> units,
  															:semester_id => Semester.current.id,
  															:offered => true)
		end
		
		offered_courses.push(db_course.number)

    # keep track of the sections parsed for the current course
    offered_sections = []
    
		# Loop through Course info, creating lectures/recitations, etc.
		begin
			# If course name is long and takes two vertical rows, move on to next row
			if isempty(cells[3]) && isempty(cells[4])
				i += 1
				if i >= rows.length
				  check_sections_offered(offered_sections, db_course.sections)
				  throw :done
				end
				cells = (rows[i]/"td")
			end
		
			section = cells[3].inner_text
			has_lecture = false
			if (islecture(section))
			  has_lecture = true
			  
			  number = getsection(section)
			  db_lecture = Lecture.includes(:course).where("courses.semester_id = ? AND courses.id = ? AND lectures.number = ?",
			                                               Semester.current.id, db_course.id, number)
			  if db_lecture.length > 0
			    db_lecture = db_lecture[0]
			    # delete current times for db_lecture
  			  ScheduledTime.find_all_by_schedulable_id_and_schedulable_type(db_lecture.id, "Lecture").each do |s|
  				  s.delete
  				end
    		  db_lecture.update_attribute(:instructor, cells[8].inner_text)
    		  db_lecture.save!
    		else
          # Create Lecture
      		db_lecture = Lecture.create(:course_id => db_course.id,
  			                              :number => getsection(section),
  			                              :instructor => cells[8].inner_text)
    		end
    		

        # TODO: populate lecture with instructor data
	
  			# Create all the Lecture Section Times, attaching them to Lecture
  			db_lec_sec_time = nil
  			begin
  			  times = validatetimes(timetominutes(cells[5].inner_text), timetominutes(cells[6].inner_text))
  				db_lec_sec_time = ScheduledTime.create(:schedulable_id => db_lecture.id,
  				                                       :schedulable_type => "Lecture",
  																							 :days 				=> validatedays(cells[4].inner_text),
  																							 :begin 			=> times[0],
  																							 :end 				=> times[1],
  																							 :location 	  => cells[7].inner_text)
  				i += 1
  				if i >= rows.length
					  check_sections_offered(offered_sections, db_course.sections)
					  throw :done
					end
  				cells = (rows[i]/"td")
  			end while isempty(cells[3]) && isempty(cells[0]) && isempty(cells[1])
	
  			abort 'Lecture section time was nil!' if !db_lec_sec_time
			end

      
			# Loop through course sections that take multiple rows
			while i < rows.length
				cells = (rows[i]/"td")
				# end of the current course, so break
				if (!isempty(cells[0]) && (cells[0].inner_text.insert(2, '-') != number)) || islecture(cells[3].inner_text)
					break
				end
		
				# If course name is long and takes two vertical rows, move on to next row
				if isempty(cells[3]) && isempty(cells[4])
					i += 1
					if i >= rows.length
					  check_sections_offered(offered_sections, db_course.sections)
					  throw :done
					end
					cells = (rows[i]/"td")
				end
				
				
				letter = getsection(cells[3].inner_text)
				db_section = Section.includes(:course).where("courses.semester_id = ? AND courses.id = ? AND sections.letter = ?",
			                                               Semester.current.id, db_course.id, letter)
			  if db_section.length > 0
			    db_section = db_section[0]
			    # delete all times for db_section
  				ScheduledTime.find_all_by_schedulable_id_and_schedulable_type(db_section.id, "Section").each do |s|
  				  s.delete
  				end
  				puts "updaitng to = " + cells[8].inner_text
			    # if we found the section, mark it now as offered in case it was previously marked not offered
			    db_section.update_attributes(Hash[:offered => true, :instructor => cells[8].inner_text])
			    db_section.save!
    		else
          # Create Section
      		db_section = Section.create(:course_id => db_course.id,
  			                              :letter => letter,
  			                              :instructor => cells[8].inner_text,
  			                              :offered => true)
    		end
				
				offered_sections.push(db_section.letter)
				
				if has_lecture
				  db_section.update_attribute(:lecture_id, db_lecture.id)
				  db_section.save!
				end

				# TODO: add instructor data
	
				db_sec_time = nil
				# Create all Section times
				begin
				  times = validatetimes(timetominutes(cells[5].inner_text), timetominutes(cells[6].inner_text))
					db_sec_time = ScheduledTime.create(:schedulable_id => db_section.id,
						                                 :schedulable_type => "Section",
																						 :days 		 => validatedays(cells[4].inner_text),
																						 :begin 	 => times[0],
      																			 :end 		 => times[1],
																						 :location => cells[7].inner_text)              
					i += 1
					if i >= rows.length
					  check_sections_offered(offered_sections, db_course.sections)
					  throw :done
					end
					cells = (rows[i]/"td")
				end while isempty(cells[3]) && isempty(cells[0]) && isempty(cells[1])
			
				abort 'Recitation section time was nil!' if !db_sec_time
			
			end

		end while isempty(cells[0])
		
		check_sections_offered(offered_sections, db_course.sections)
	
	end
end

# check if any courses are not in offered_courses, i.e. they are no longer offered
Course.all.each do |c|
  if !offered_courses.include?(c.number)
    # course not found anymore, mark it not offered!
    c.update_attribute(:offered, false)
    c.save!
  end
end
