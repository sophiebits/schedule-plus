class FriendsController < ApplicationController
  def show
    if (params[:id])
      @friend = User.find(params[:id])
      if friends.exists? @friend
        if request.xhr?
          
        else
          @schedule = @friend.main_schedule
          render 'schedules/show'
        end
      else
        redirect_to friends_path
      end
    else
      @friends = friends
    end
  end
end
