class SchedulesController < ApplicationController

  def index
    redirect_to root_path if !user_signed_in?
    @schedules = current_user.schedules
  end

  def show
    if (params[:id]) 
      @schedule = Schedule.find_by_url(params[:id])
    elsif current_user
      @schedule = current_user.main_schedule || Schedule.new
    end
    redirect_to root_path if @schedule.nil?
  end
  
  def new
    
  end
 
  def create
    redirect_to root_path if !current_user
    semester_id = params[:semester] || current_semester.id
    @schedule = current_user.schedules.create(:semester_id => semester_id)
    @schedule.copy!(Schedule.find_by_url(params[:clone])) if params[:clone]
    redirect_to schedule_path(@schedule)
  end

  def destroy
    @schedule = Schedule.find_by_url(params[:id])
    @schedule.destroy
    respond_to do |format|
      format.html { redirect_to schedules_path }
      format.js
    end
  end

  def update
    @schedule = Schedule.find_by_url(params[:id])
    if params[:schedule][:active]
      @schedule.make_active!
    else
      @schedule.update_attributes(params[:schedule])
    end
    flash[:notice] = "Updated successfully."
    respond_to do |format|
      format.html { redirect_to schedule_path(@schedule) }
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

end
