class SchedulesController < ApplicationController
  def import
    # Parser.parse(params[:url])
    # if valid
    #   if request.xhr?
    #     
    #   else
    #     flash[:notice] = "Imported Schedule."
    #     redirect_to schedule_path(...)
    #   end
    # else
    #   if request.xhr?
    #     render :status => 403
    #   else
    #     flash[:error] = "Schedule could not be imported. Check your Scheduleman URL and try again."
    #     redirect_to schedule_path(...)
    #   end
    # end
     
    @schedule = User.find(3)
    if request.xhr?
      render :json => 
        @schedule.to_json(:include => {
          :scheduled_courses => {:include => 
            {
              :course => {}, 
              :lecture => {:include => :lecture_section_times}, 
             :recitation => {:include => :recitation_section_times}
            }
          }
        })
    else
      redirect_to schedules_path
    end
  end
  
  def new
    # release 2
  end

  def show
    @schedule = User.find(3)
    if request.xhr?
      render :json => 
        @schedule.to_json(:include => {
          :scheduled_courses => {:include => 
            {
              :course => {}, 
              :lecture => {:include => :lecture_section_times}, 
              :recitation => {:include => :recitation_section_times}
            }
          }
        })
    else
        
    end
  end

	def get_friends_in_course
		if request.xhr?
			scheduled_course_id = params[:scheduled_course_id]
			course_id = params[:course_id]

			friends_includes = friends.includes(:scheduled_courses => [:course])
			if scheduled_course_id
				render :json => friends_includes.where('scheduled_courses.id = ?', scheduled_course_id).to_json
			elsif course_id
				render :json => friends_includes.where('courses.id = ?', course_id).to_json
			end
		else
			redirect_to schedules_path
		end
	end
end
