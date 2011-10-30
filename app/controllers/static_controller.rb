class StaticController < ApplicationController

  def home
    if user_signed_in?
      if current_user.main_schedule(current_semester)
        redirect_to schedule_path(current_user.main_schedule(current_semester))
      else
        redirect_to schedules_path
      end 
    end
  end

  def tos

  end

  def privacy

  end

end
