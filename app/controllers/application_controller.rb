require 'fb_graph'

class ApplicationController < ActionController::Base
  protect_from_forgery
  
  # Always redirect users to scheduleplus.org if they try to access thourgh the heroku site
  before_filter :check_uri, :check_schedule
  def check_uri
	  redirect_to 'http://scheduleplus.org' if /heroku/.match(request.host)
  end

  def check_schedule
    if current_user && !current_user.main_schedule
      redirect_to new_schedules_path if request.env['PATH_INFO'] != new_schedules_path
    end
  end
  
  helper_method :current_user, :fb_user, :friends

	@current_user = nil
	@fb_user = nil
	@friends = nil

  private

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end
  
  def fb_user
    @fb_user ||= FbGraph::User.me(session[:token]).fetch if session[:token]
  end

  def friends
    if @friends.nil?
      fb_friends = fb_user.friends.collect{|f|f.identifier} if fb_user
      fb_friends_uids = []
      User.all.each do |u|
        fb_friends_uids.push(u.uid) if fb_friends.include? u.uid
      end
      @friends = User.where("users.uid IN (?) AND users.id IN (SELECT user_id FROM active_schedules)", fb_friends_uids)
    end
    @friends
  end
  
  rescue_from FbGraph::Unauthorized do |exception|
    reset_session
    redirect_to root_path
  end
end
