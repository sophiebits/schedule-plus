class CourseSelectionsController < ApplicationController

  load_and_authorize_resource :except => [:create]
  # POST
  # FIXME this method is bloated to shit. please fix
  def create
    schedule = Schedule.find_by_url(params[:schedule_id]) or
      raise ActiveRecord::RecordNotFound

    if current_user == schedule.user
      if params[:search]
        parsed = parse_search(params[:search])
        search = parsed[0]
        section_letter = parsed[1] ? parsed[1].upcase : nil
        @results = Rails.cache.fetch(search+'*semester='+params[:semester].to_s) do
                     Course.by_semester(Semester.find(params[:semester]))
                           .search(search)
                           .select(&:offered)
                   end
        @results = @results.select {|c| !(schedule.courses.include?c) }
        if params[:confirm]
          if @results.length == 1 
            course = @results.first
            section = course.find_by_section(section_letter).try(:id) ||
                      course.sections.first.id
            @selection = schedule.add_course(section)
          else
            @search = params[:search]
          end
        end
        @search_term = params[:search]
      else
        @selection = schedule.add_course(params[:id])
      end
    end
    @no_selections = schedule.course_selections.empty?

    respond_to do |format|
      format.html { redirect_to schedule_path(params[:schedule_id]) }
      format.js
    end
  end

  # PUT
  def update
    @selection = Schedule.find_by_url(params[:schedule_id])
                         .switch_section(params[:section_id])
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
  
  # parses the search query into [course name/number, section letter]
  # (section letter is nil if not specified)
  def parse_search(search)
    if search.length >= 4
      # get the last 2 characters in the search
      section = search[-2,2]
      if is_letter?(section[1]) and (section[0] == ' ' or is_number?(section[0]))
        # 1-letter section: first char is a space/number; second char is a letter
        return [search[0..-2], section[1]]
      elsif is_letter?(section[0]) and (is_number?(section[1]) or is_letter?(section[1]))
        # 2-letter section: first char is a letter; second char is a number or letter
        return [search[0..-3], section]
      end
    end
    return [search, nil]
  end
  
  private

  def is_letter?(letter)
    letter[/[a-zA-Z]/] == letter
  end
  
  def is_number?(number)
    number[/[0-9]/] == number
  end

end
