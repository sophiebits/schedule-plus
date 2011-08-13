require 'open-uri'
require 'net/https'

class SessionsController < ApplicationController
  def show
     auth = request.env['omniauth.auth']
     user = User.find_by_uid(auth['uid']) || User.create_with_omniauth(auth)
    
    session[:user_id] = user.id
    session[:token] = auth['credentials']['token']
    redirect_to root_url
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_url
  end
end
