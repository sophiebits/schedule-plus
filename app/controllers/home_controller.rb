class HomeController < ApplicationController
  def index
    # Clear any schedules that may have been imported earlier
    session[:imported] = nil
    
    if current_user
      redirect_to schedules_path
    end
  end
  
  def main
    if request.xhr?
      @schedule = Schedule.find(params[:schedule])
      render 'schedules/show', :layout => false
    else
      redirect_to root_path
    end
  end
end
