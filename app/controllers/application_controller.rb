require 'fb_graph'

class ApplicationController < ActionController::Base
  protect_from_forgery

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, :alert => "You cannot see other user's data you sneaky user you"
  end

  # Always redirect users to scheduleplus.org if they try to access through the heroku site
  # before_filter :check_uri
  def check_uri
    redirect_to 'http://scheduleplus.org' if /heroku/.match(request.host)
  end

  helper_method :current_semester, :current_user, :user_signed_in?
  
  private
  
  def user_signed_in?
    !current_user.nil?
  end

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  # Set Default Semester
  def current_semester
    @current_semester ||= Semester.current
  end
  
  rescue_from FbGraph::InvalidRequest do |e|
    reset_session
    redirect_to root_path
  end
  
  rescue_from FbGraph::Unauthorized do |exception|
    reset_session
    redirect_to root_path
  end
end
