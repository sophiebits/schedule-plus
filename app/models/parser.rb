require 'rubygems'
require 'ri_cal'
require 'net/http'
require 'open-uri'
require 'openssl'
require 'hpricot'

def getsection(sec)
  if sec.include? 'Lec'
    if sec == 'Lec'
      return '1'
    end
    return sec[-1,1]
  end
  sec
end

class Parser < ActiveRecord::Base

  # creates a course selection with number and section letter for schedule in
  # response[:schedule]
  def self.create_course_selection(number, section_letter, response)
    begin
      section = Course.find_by_number_and_semester_id(number, response[:schedule].semester.id).sections.find_by_letter(section_letter)
    rescue
      section = nil
    end
    if !section
      Logger.new(STDOUT).info(number + ' ' + section_letter + ' does not exist in db!')
      response[:warnings].push(number)
      return
    end
    response[:schedule].add_course(section.id)
  end
  
  # Parse method for SIO calendar file
  def self.parseSIO(file, schedule)
    @components = RiCal.parse(file)
    
    response = Hash.new
    response[:warnings] = []
    response[:schedule] = schedule
     
    @components.first.events.each do |course| 
      summary = course.summary.split('::')[1].strip.split(' ')
      if summary.count > 0
        number = summary[0].insert(2,'-')
        section_letter = summary[1]
        self.create_course_selection(number, section_letter, response)
      end
    end
    
    self.check_errors(response)
  end

  # Parse method for scheduleman url
  def self.parseScheduleman(url, schedule)
    #if the link has a trailing '/' remove it
    if (url[url.length-1] == '/')
       url[url.length-1] = ''
    end
    #if the url has a trailing '.ics' remove it
    if ((url[url.length-4,url.length-1]).eql?(".ics"))
       url = url[0..(url.length-5)]
    end
    #if the url is http, add in the 's' to make it https
    if ((url[0..4]).eql?("http:"))
       url = "https" + url[4..(url.length-1)]
    end
    #if the url doesnt have any http/https protocal prefix, add it
    if (!url.include?("https://"))
       url = "https://" + url
    end

    #append .ics to get the file from scheduleman server, not the html code
    file_url = url + ".ics"
    begin
      open(file_url) do |file|
        @components = RiCal.parse(file)
      end
    rescue
      return
    end
    
    response = Hash.new
    response[:warnings] = []
    response[:schedule] = schedule
    
    if schedule.nil?
      return
    end

    # add course selections for each course
    @components.first.events.each do |course| 
      summary = course.summary.delete('"').split(' ')
      if summary.include? "Lec"
        next
      end
      number = summary[-2]
      section_letter = getsection(summary[-1])
      
      self.create_course_selection(number, section_letter, response)
    end
    
    # Need to check for TBA courses in scheduleman
    doc = open(url) { |f| Hpricot(f) }
    total_units = (doc/"#total-units").first.inner_text
    
    if total_units
      total_units = total_units[/.*total:(.*?)units/,1].strip
      if schedule.units != total_units
        # Units are different; need to parse TBA courses on the scheduleman
        courses = (doc/".course")
        scheduled_course_numbers = schedule.courses.collect{|c| c.number}
        # Check each course in tehe html to find which one's aren't included in the user's schedule
        courses.each do |c|
          number = (c/".number").inner_text.strip[0,6]
          if !scheduled_course_numbers.include? number
            section_letter = (c/".selected_section").inner_text.strip
            self.create_course_selection(number, section_letter, response)
          end
        end
      end
    end
    
    self.check_errors(response)
  end
  
  def self.check_errors(response)
    p response[:schedule].units.split('-')[0].to_s
    # Check that schedule doesn't have over 100 units
    if response[:schedule].units.split('-')[0].to_f > 100.0
      response[:error] = "Schedule is too large (total units are over 100)"
    end
    
    response
  end
end
