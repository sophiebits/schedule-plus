class AuthenticationsController < ApplicationController
  def index
    @authentications = current_user.authentications if user_signed_in?
  end

  def create
    omniauth = request.env['omniauth.auth']
    auth = Authentication.find_by_provider_and_uid(omniauth['provider'], 
                                                   omniauth['uid'])
    if auth
      flash[:notice] = "Signed in successfully."
      auth.update_attribute(:token, (omniauth['credentials']['token'] rescue nil))
      session[:user_id] = auth.user.id
      redirect_to root_url
    elsif user_signed_in?
      current_user.authentications.create!(:provider => omniauth['provider'], 
                                           :uid      => omniauth['uid'],
                                           :token => (omniauth['credentials']['token'] rescue nil))
      flash[:notice] = "Authentication successful."
      redirect_to authentications_url
    else
      user = User.new
      user.apply_omniauth(omniauth)
      user.save
      
      flash[:notice] = "Signed in successfully."
      session[:user_id] = user.id
      redirect_to root_url
    end
  end

  def destroy
    if user_signed_in?
      if params[:id]
        @authentication = current_user.authentications.find(params[:id])
        @authentication.destroy
      else
        @authentications = current_user.authentications
        @authentications.map{|a| a.update_attribute(:token, nil) }
      end
    end
    redirect_to root_url
  end

  protected

  def handle_unverified_request
    true
  end
end
