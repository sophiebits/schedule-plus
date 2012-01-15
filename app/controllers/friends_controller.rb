class FriendsController < ApplicationController
  def index   
    redirect_to root_path if !user_signed_in?
    @friends = current_user.friends
  end

end
