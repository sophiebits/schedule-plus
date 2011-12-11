class CourseSelectionsController < ApplicationController
  # POST
  def create
    schedule = Schedule.find_by_url(params[:schedule_id])
    if params[:search]
      # TODO text input parsing  
      results = Course.search(params[:search])
      if results.length == 1
        
      end
      #redirect_to courses_path(:search => params[:search])
      redirect_to schedule_path(params[:schedule_id])
    else
      Schedule.find_by_url(params[:schedule_id]).add_course(params[:id])
      redirect_to schedule_path(params[:schedule_id])
    end
  end

  # PUT
  def update
    Schedule.find_by_url(params[:schedule_id]).add_course(params[:section_id])
    redirect_to schedule_path(params[:schedule_id])
  end

  # DELETE
  def destroy
    CourseSelection.find(params[:id]).destroy
    redirect_to schedule_path(params[:schedule_id])
  end

end
