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
      user.update_active_schedule(imported_schedule)
      
      session[:imported] = nil
		end

    render :text => '<script type="text/javascript">if(window.opener){window.opener.location.reload(true);window.close();}else{window.location("/schedules");}</script>', :layout => false
    #redirect_to schedules_url
  end

  def destroy
    reset_session
    redirect_to root_url
  end

  # user cancelled facebook authentication. we do nothing.
  def bounce
    render :text => '<script type="text/javascript">if(window.opener){window.close();}</script>', :layout => false
  end
end
