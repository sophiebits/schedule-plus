require 'fb_graph'

class ApplicationController < ActionController::Base
  protect_from_forgery
  
  # Always redirect users to scheduleplus.org if they try to access through the heroku site
  # before_filter :check_uri
  def check_uri
	  redirect_to 'http://scheduleplus.org' if /heroku/.match(request.host)
  end

  #helper_method :friends
	#@friends = nil

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
  
  #def friends
  #  if @friends.nil?
  #    fb_friends = fb_user.friends.collect{|f|f.identifier} if fb_user
  #    fb_friends_uids = User.all.collect{|u| u.uid if fb_friends.include? u.uid and u.main_schedule}.compact
  #    @friends = User.where(:uid => fb_friends_uids)
  #  end
  #  @friends
  #end
  
  rescue_from FbGraph::InvalidRequest do |e|
    reset_session
    redirect_to root_path
  end
  
  rescue_from FbGraph::Unauthorized do |exception|
    reset_session
    redirect_to root_path
  end
end
