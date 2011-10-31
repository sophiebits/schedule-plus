require 'fb_graph'

class ApplicationController < ActionController::Base
  protect_from_forgery
  
  # Always redirect users to scheduleplus.org if they try to access thourgh the heroku site
  before_filter :check_uri
  def check_uri
	  redirect_to 'http://scheduleplus.org' if /heroku/.match(request.host)
  end

  #helper_method :friends
	#@friends = nil

  helper_method :current_semester, :resource_name, :resource, :devise_mapping, :devise_error_messages! 
  
  private
  
  # Set Default Semester
  def current_semester
    @current_semester ||= Semester.current
  end
  
  ##############################################################
  # Devise helper methods
  ##############################################################
  def resource_name
    :user
  end

  def resource
    @resource ||= User.new
  end

  def devise_mapping
    @devise_mapping ||= Devise.mappings[:user]
  end
  
  def devise_error_messages!
    return "" if resource.errors.empty?

    messages = resource.errors.full_messages.map { |msg| content_tag(:li, msg) }.join
    sentence = I18n.t("errors.messages.not_saved",
                      :count => resource.errors.count,
                      :resource => resource_name)

    html = <<-HTML
    <div id="error_explanation">
    <h2>#{sentence}</h2>
    <ul>#{messages}</ul>
    </div>
    HTML

    html.html_safe
  end
 
  ##############################################################

  #def friends
  #  if @friends.nil?
  #    fb_friends = fb_user.friends.collect{|f|f.identifier} if fb_user
  #    fb_friends_uids = User.all.collect{|u| u.uid if fb_friends.include? u.uid and u.main_schedule}.compact
  #    @friends = User.where(:uid => fb_friends_uids)
  #  end
  #  @friends
  #end
  
  rescue_from FbGraph::Unauthorized do |exception|
    reset_session
    redirect_to root_path
  end
end
