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
# puts '    instrctr:  ' + map[:instructor]
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

# returns time as an integer in number of minutes since midnight
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

# format units into "lower-upper" format, e.g. "9.0-12.0"
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

# check if any sections are not in offered_sections, i.e. they are no longer offered
def check_sections_offered(offered_sections, db_sections)
  db_sections.each do |sec|
    if !offered_sections.include?(sec.letter)
      # section not found anymore, mark it not offered!
      sec.update_attribute(:offered, false)
      sec.save!
    end
  end
end

# shorten the semester name into SoC format, e.g. "S12"
def shorten_semester_name(sem_name)
  if sem_name
    # "Spring 2012" ==> "S" + "12" ==> "S12"
    begin
      return sem_name[0]+sem_name[-2,2]
    rescue
      ""
    end
  end
  ""
end

# populate course with data (descriptions, prereqs, coreqs)
def populate_course_data(course)
  course_url = "https://enr-apps.as.cmu.edu/open/SOC/SOCServlet?CourseNo=%s&SEMESTER=%s&Formname=Course_Detail" % [course.number.sub('-',''), shorten_semester_name(course.semester.name)]
  begin
    doc = open(course_url) { |f| Hpricot(f) }
  rescue
    return
  end
  if doc.inner_text.include?("technical difficulty")
    return
  end
  
  if doc
    info = doc.search("//font")
    i = 0
    # loop through <font> tags in the document
    while info[i]
      s = info[i].inner_text.strip

      case s
      when "Description:"

        i = i + 1
        desc = info[i].inner_text.strip
        course.update_attribute(:description, desc)
      when "Prerequisites:"
        i = i + 1
        pre = info[i].inner_text.strip
        course.update_attribute(:prereqs, pre)
        i = i + 2
        co = info[i].inner_text.strip
        course.update_attribute(:coreqs, co.split(' ').join(''))
      end

      i = i + 1
    end
  end
  course.save!
end


class Seeder < ActiveRecord::Base
  # seeds db with semester data
  def self.seed_semesters
    # add new semesters to this list over time
    semesters = ["Fall 2011", "Spring 2012"]
    # set this variable to the name of the current semester
    current_semester_name = semesters[1]
    
    # scan through all semesters and add or update them accordingly in the database
    semesters.each do |name|
      sem = Semester.find_by_name(name)
      if sem.nil?
        Semester.create(:name => name, :current => (current_semester_name == name),
                        :short_name => name[0] + name[-2,2])
      else
        sem.update_attribute(:current, current_semester_name == name)
        sem.save!
      end
    end
  end
  
  # seeds db with SoC data, and updates courses/lectures/sections to the newest information
  # Note: uses the current semester if the semester variable is nil
  def self.seed_soc(semester)
    # if semester is nil, use current semester
    semester ||= Semester.current
    
    # @jm: use real SoC data later
    file = 'sched_layout_spring.html'
    #file = "https://enr-apps.as.cmu.edu/assets/SOC/sched_layout_%s.htm" % semester.name.split(' ')[0].downcase

    if Rails.env.production?
      parse_file = File.new("#{RAILS_ROOT}/tmp/parse_file_#{Process.pid}.html", "w")
    else
      parse_file = File.new("parse_file.html", "w")
    end
    begin
      file = open(file)
    rescue
      p "Couldn't open " + file
      return
    end
  
  lines = File.readlines(file)
  
  if !(lines.any? { |s| s.include?(semester.name) })
    puts "*** Error: wrong semester data ***"
    # @jm: uncomment this when using real SoC Data
    #return
  end
  
  puts "> Semester: " + semester.name 

    lines.each do |line|
      if line.include? 'Lec/Sec'
        open(parse_file, 'a') { |f| f.puts '<TABLE>' }
      elsif line[0..2] == "<TD"
        open(parse_file, 'a') { |f| f.puts "<TR>" + line }
      else
        open(parse_file, 'a') { |f| f.puts line }
      end
    end

    doc = open(parse_file) { |f| Hpricot(f) }    
    table = doc.search("//table")
    rows = (table/"tr")

    # use to build list of all courses seen in the SoC html
    offered_courses = []
    
    # the name of the current department being parsed in the html
    current_department_name = nil

    catch(:done) do
      i = 0
      while i < rows.length

        cells = (rows[i]/"td")

        # Not a department name or course
        if (cells[0].inner_text == 'Course') || isempty(cells[0])
          i += 1
          next
        end
        
        # Department name
        if !isempty(cells[0]) && isempty(cells[1])
          current_department_name = cells[0].inner_text.strip
          puts "\nDepartment: " + current_department_name
          i += 1
          next
        end

        throw :done if i >= rows.length

        abort 'Error (1)' if isempty(cells[0]) || isempty(cells[1]) || isempty(cells[2])

        # Prints name and number so that I know something's happening
        print cells[0].inner_text + ' ' + cells[1].inner_text

        number = cells[0].inner_text
        number.insert(2, '-')

        name = cells[1].inner_text
        units = reformatunits(cells[2].inner_text)
        
        current_department = Department.find_by_name(current_department_name)
        if current_department.nil?
          Department.create(:prefix => number[0..1], :name => current_department_name)
        elsif !current_department.prefix.include?(number[0..1])
          # add to prefixes if multiple prefixes exist for this department
          current_department.update_attribute(:prefix, current_department.prefix + ":" + number[0..1])
        end

        db_course = Course.find_by_semester_id_and_number(semester.id, number)
        exists = !db_course.nil?

        if db_course 
          db_course.update_attributes(Hash[:name => name, :units => units, :offered => true])
          puts '...updated!' if db_course.save!
        else
          # Create Course
          db_course = Course.create(:number => number,
                                    :name   => name,
                                    :units  => units,
                                    :semester_id => semester.id,
                                    :offered => true)
          puts ""
        end

        populate_course_data(db_course)
        offered_courses.push(db_course.number)

        # keep track of the sections seen for the current course
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
                                                         semester.id, db_course.id, number)
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
                                                     :days        => validatedays(cells[4].inner_text),
                                                     :begin       => times[0],
                                                     :end         => times[1],
                                                     :location    => cells[7].inner_text)
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
                                                         semester.id, db_course.id, letter)
            if db_section.length > 0
              db_section = db_section[0]
              # delete all times for db_section
              ScheduledTime.find_all_by_schedulable_id_and_schedulable_type(db_section.id, "Section").each do |s|
                s.delete
              end
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
                                                 :days     => validatedays(cells[4].inner_text),
                                                 :begin    => times[0],
                                                 :end      => times[1],
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
    Course.by_semester(semester).each do |c|
      if !offered_courses.include?(c.number)
        # course not found anymore, mark it not offered!
        p 'X ' + c.number
        c.update_attribute(:offered, false)
        c.save!
      end
    end

    true
  end
end
