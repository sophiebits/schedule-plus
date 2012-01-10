class UsersController < ApplicationController
  def show
    # FIXME !!!! restrict access to non-private users
    if user_signed_in?
      @user = User.find(params[:id])
    else
      redirect_to root_url
    end
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
