class StaticController < ApplicationController

  def home
    if user_signed_in?
      redirect_to schedules_path
    else
      render :layout => false
    end
  end

  def tos

  end

  def privacy

  end

end
