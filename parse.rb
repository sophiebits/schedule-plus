require 'ri_cal'


class Parser

  def self.parse(file)
     
    File.open(file,"r") do |file|
      @@components = RiCal.parse(file)
    end 
      
    @@components.first.events.each do |course| 
      name = course.description
      start_time = course.dtstart
      location = course.location 
      summary = course.summary #course number and section here, find way to better parse this
      duration = course.duration      
            
      puts summary
      # puts "#{summary}\n\n"
       if !course.summary.include? "Lec"
         #puts "#{course.summary}\n\n------------------------\n" 
         if course.summary.include? "Mini"
            number = course.summary.split(/ /)[1]
            puts number
            section = course.summary.split(/ /)[2][0]
            puts section
         else
            number = course.summary.split(/ /)[0]
            if number.slice(0) == "\""
              number[0] = ''
              puts number
              section = course.summary.split(/ /)[1][0]
              puts section
            else
              puts number
            end 
         end
       end
    end   



    nil
  end

end
