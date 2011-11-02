class FriendsController < ApplicationController
  def index   
    if !user_signed_in?
      redirect_to root_path
    end
    @friends = current_user.friends
  end
end
