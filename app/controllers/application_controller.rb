require 'fb_graph'

class ApplicationController < ActionController::Base
  protect_from_forgery
  
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
      fb_friends = fb_user.friends if fb_user
      fb_friends_uids = []
      fb_friends.each do |f|
        fb_friends_uids.push(f.identifier)
      end
      @friends = User.where(:uid => fb_friends_uids)
                     .where("id NOT IN (SELECT user_id FROM active_schedules)")
      @friends.sort!{ |f1, f2| f1.name <=> f2.name }
    end
    @friends
  end
  
  rescue_from FbGraph::Unauthorized do |exception|
    reset_session
    redirect_to root_path
  end
end
