class StaticController < ApplicationController

  def home
    if user_signed_in?
      if current_user.main_schedule(Semester.current)
        redirect_to schedule_path(current_user.main_schedule(Semester.current))
      else
        redirect_to schedules_path
      end
    else
      render :layout => false
    end
  end

  def tos

  end

  def privacy

  end

end
