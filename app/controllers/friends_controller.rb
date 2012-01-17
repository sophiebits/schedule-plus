class FriendsController < ApplicationController
  def index   
    redirect_to root_path if !user_signed_in?
    @friends = current_user.friends
    @curr_friends = @friends.reject {|f| f.main_schedule(current_semester).nil? }
    @prev_friends = @friends.select {|f| f.main_schedule(current_semester).nil? }
  end

end
