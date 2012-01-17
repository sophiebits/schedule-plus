class SchedulesController < ApplicationController

  def index
    if !user_signed_in?
      redirect_to root_path 
    else
      @schedules = current_user.schedules
    end
  end

  def show
    @schedule = Schedule.find_by_url(params[:id]) or not_found
  end
  
  def new
    
  end
 
  def create
    if !user_signed_in?
      redirect_to root_path
    else
      semester_id = params[:semester] || current_semester.id
      @schedule = current_user.schedules.create(:semester_id => semester_id)
      if (current_user.schedules.select{|sched| sched.semester_id == semester_id}.length == 1)
        @schedule.update_attribute(:primary, true)
      end
      if params[:clone]
        # TODO check cloning semesters are the same
        to_clone = Schedule.find_by_url(params[:clone]) or not_found
        @schedule.copy!(to_clone)
        @schedule.update_attribute(:name, @schedule.name + ' (clone)')
      end
      redirect_to schedule_path(@schedule)
    end
  end

  def destroy
    @schedule = Schedule.find_by_url(params[:id]) or not_found
    @schedule.destroy
    @none_left = current_user.schedules.by_semester(@schedule.semester).empty?
    respond_to do |format|
      format.html { redirect_to schedules_path }
      format.js
    end
  end

  def update
    @schedule = Schedule.find_by_url(params[:id]) or not_found
    if params[:schedule][:primary]
      @schedule.make_primary!
    else
      @schedule.update_attributes(params[:schedule])
    end
    flash[:notice] = "Updated successfully."
    respond_to do |format|
      format.html { redirect_to schedule_path(@schedule) }
      format.js
    end
  end
  
  def rename
  	@schedule = Schedule.find(params[:schedule_id]) or not_found
  	if params[:new_name]
  		@schedule.rename(params[:new_name])
  	end
  	respond_to do |format|
      format.html { redirect_to '/schedules/' }
      format.js
    end
  end

  def import
    @schedule = Schedule.find(params[:schedule_id])
    if !params[:scheduleman_url].empty? && !@schedule.nil?
      Parser.parseScheduleman(params[:scheduleman_url], @schedule)
    end
    respond_to do |format|
      format.html { redirect_to schedule_path(@schedule) }
      format.js
    end
  end

  private

  def not_found
    raise ActiveRecord::RecordNotFound
  end

end
