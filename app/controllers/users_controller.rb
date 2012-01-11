class UsersController < ApplicationController
  load_and_authorize_resource
 def show
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
