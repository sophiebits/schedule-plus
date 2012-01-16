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
      if params[:clone]
        # TODO check cloning semesters are the same
        to_clone = Schedule.find_by_url(params[:clone]) or not_found
        @schedule.copy!(to_clone)
      end
      redirect_to schedule_path(@schedule)
    end
  end

  def destroy
    @schedule = Schedule.find_by_url(params[:id]) or not_found
    @schedule.destroy
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
    if params[:import]
      # Parse uploaded .ics file
      file = params[:import][:uploaded_file].tempfile
      parsed = Parser.parseSIO(file)   
    else
      # Parse scheduleman url
      parsed = Parser.parse(params[:url])
    end
    
    if current_user
      # authenticated, update active_schedule
      current_user.update_active_schedule(parsed[:schedule])
    else
      # store imported schedule id in session var to retrieve after oauth
      session[:imported] = parsed[:schedule].id
    end

    if request.xhr?
      render :json => parsed
    else
      redirect_to '/schedules/' + session[:imported].to_s
    end
  end

  private

  def not_found
    raise ActiveRecord::RecordNotFound
  end

end
