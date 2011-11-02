class SchedulesController < ApplicationController

  def index
    redirect_to root_path if !user_signed_in?
    @schedules = current_user.schedules.group_by { |s| s.semester }
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
    @schedule = current_user.schedules.create(:semester_id => current_semester)
    @schedule.update_attribute(:active, true) if 
      current_user.schedules.by_semester(current_semester).length == 1
    render "show"
  end

  def destroy
    @schedule = Schedule.find_by_url(params[:id])
    @schedule.destroy
    redirect_to schedules_path
  end

  def update
    @schedule = Schedule.find_by_url(params[:id])
    if params[:schedule][:active]
      # make all other semester schedules inactive
      current_user.schedules.by_semester(@schedule.semester).each do |s|
        s.update_attribute(:active, false)
      end
    end
    @schedule.update_attributes(params[:schedule])
    flash[:notice] = "Updated successfully."
    redirect_to schedules_path
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

	def get_friends_in_course
		if request.xhr?
			scheduled_course_id = params[:scheduled_course_id].to_i
			course_id = params[:course_id].to_i

			friends_includes = friends.includes(:main_schedule => {:scheduled_courses => 
        [:course]})
			
      # if scheduled_course_id
        response = Hash.new
        response[:data] = Hash.new

        response[:data][:same_section] = friends_includes.where('scheduled_courses.id = ?', scheduled_course_id).order('users.name')
        response[:data][:other_section] = friends_includes.where('courses.id = ? AND scheduled_courses.id <> ?', course_id, scheduled_course_id).order('users.name')
        
        response[:me] = Hash.new
        if current_user.main_schedule.scheduled_courses.exists? scheduled_course_id
          response[:me][:same_section] = current_user
        elsif current_user.main_schedule.scheduled_courses.collect{|sc| sc.course_id}.include? course_id
          response[:me][:other_section] = current_user
        end

        render :json => response.to_json
      #       elsif course_id
      #   render :json => friends_includes.where('courses.id = ?', course_id).order('users.name').to_json
      # end

		else
			redirect_to schedules_path
		end

	end

end
