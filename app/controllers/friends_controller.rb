class FriendsController < ApplicationController
  def index
    if !current_user
      redirect_to root_path
    end
    @friends = friends
  end
  
  def show
    if !current_user 
      redirect_to root_path
    else

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
end
