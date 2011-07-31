require 'fb_graph'

class ApplicationController < ActionController::Base
  protect_from_forgery
  
  helper_method :current_user, :fb_user

  private

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end
  
  def fb_user
    @fb_user ||= FbGraph::User.me(session[:token]).fetch if session[:token]
  end

  

end
