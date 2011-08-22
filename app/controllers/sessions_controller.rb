require 'open-uri'
require 'net/https'

class SessionsController < ApplicationController
  def show
    auth = request.env['omniauth.auth']
    user = User.find_by_uid(auth['uid']) || User.create_with_omniauth(auth)
    
    session[:user_id] = user.id
    session[:token] = auth['credentials']['token']

		# Updated the imported schedule with the correct user id, and make it active
		if session[:imported]
			imported_schedule = Schedule.find(session[:imported])
			imported_schedule.update_attribute(:user_id, user.id)
			imported_schedule.save
			
			# Find the current user's active schedule and update it to be the imported
			# schedule, or create a new active schedule
			active_schedule = ActiveSchedule.find_by_user_id(user.id)
			if active_schedule
				active_schedule.update_attribute(:schedule_id, imported_schedule.id)
				active_schedule.save
			else
				ActiveSchedule.create(:user_id => user.id, :schedule_id => imported_schedule.id)
			end

      session[:imported] = nil
		end
	  
    render :text => '<script type="text/javascript">window.opener.location.reload(true);window.close()</script>', :layout => false
    #redirect_to schedules_url
  end

  def destroy
    reset_session
    redirect_to root_url
  end
end
