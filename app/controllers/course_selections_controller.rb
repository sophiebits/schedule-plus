class CourseSelectionsController < ApplicationController
  # POST
  def create
    schedule = Schedule.find_by_url(params[:schedule_id])
    if params[:search]
      # TODO text input parsing  
      results = Course.search(params[:search])
      if results.length == 1
        p "ONE"
        @selection = schedule.add_course(results.first.sections.first.id)
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

end
