class UsersController < ApplicationController
  def show
    # FIXME !!!! restrict access to non-private users
    user = User.find(params[:id])
    if user && user.main_schedule(current_semester)
      @schedule = user.main_schedule(current_semester)
    else
      # TODO send 404
    end
    # FIXME include schedules.css
    render "/schedules/show"
  end

  def edit
    if user_signed_in?
      @user = current_user
    else
      # TODO redirect to devise
      redirect_to root_url
    end
  end
end
