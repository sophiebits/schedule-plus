class CourseSelectionsController < ApplicationController
  # POST
  def create
    schedule = Schedule.find_by_url(params[:schedule_id])
    if params[:search]
      # TODO text input parsing  
      parsed = parse_search(params[:search])
      search = parsed[0]
      section_letter = parsed[1] ? parsed[1].upcase : nil
      
      results = Course.search(search)
      if results.length == 1
        p "ONE"
				section = results.first.find_by_section(section_letter)
				section_id = section ? section.id : nil
        if section_id
        	@selection = schedule.add_course(section_id)
        else
       		@selection = schedule.add_course(results.first.sections.first.id)
       	end
        respond_to do |format|
          format.html { redirect_to schedule_path(params[:schedule_id]) }
          format.js
        end
      else
        p "MORE"
        redirect_to courses_path(:search => params[:search])
        # redirect_to schedule_path(params[:schedule_id])
      end
    else
      @selection = Schedule.find_by_url(params[:schedule_id]).add_course(params[:id])
      respond_to do |format|
        format.html { redirect_to schedule_path(params[:schedule_id]) }
        format.js
      end
    end
  end

  # PUT
  def update
    @selection = Schedule.find_by_url(params[:schedule_id]).add_course(params[:section_id])
    respond_to do |format|
      format.html { redirect_to schedule_path(params[:schedule_id]) }
      format.js
    end
  end

  # DELETE
  def destroy
    @selection = CourseSelection.find(params[:id]).destroy
    respond_to do |format|
      format.html { redirect_to schedule_path(params[:schedule_id]) }
      format.js
    end
  end
  
  private
  
  def parse_search(search)
  	# get the last 2 characters in the search
  	section = search[-2,2]
  	if is_letter?(section[1]) and (section[0] == ' ' or is_number?(section[0]))
  		# 1-letter section: first char is a space/number; second char is a letter
  		return [search[0..-2], section[1]]
  	elsif is_letter?(section[0]) and is_number?(section[1])
  		# 2-letter section: first char is a letter; second char is a number
  		return [search[0..-3], section]
  	end
  	return [search, nil]
  end
  
  def is_letter?(letter)
  	letter[/[a-zA-Z]/] == letter
  end
  
  def is_number?(number)
  	number[/[0-9]/] == number
  end

end
