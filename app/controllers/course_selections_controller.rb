class CourseSelectionsController < ApplicationController
  
  # TODO authorize and sanitize

  # POST
  def create
    Schedule.find_by_url(params[:schedule_id]).add_course(params[:id])
    redirect_to schedule_path(params[:schedule_id])
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
