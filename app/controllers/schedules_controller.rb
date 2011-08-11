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
end
