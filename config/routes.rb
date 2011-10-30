AcmSchedule::Application.routes.draw do
  
  root :to => "static#home"
  match "/tos" => "static#tos"
  match "/privacy" => "static#privacy"
  
  ################ Devise + Omniauth ####################
  devise_for :users, :path_names => { :sign_in => 'login', 
                                      :sign_out => 'logout', 
                                      :registration => 'register' },
                     :controllers => { :registrations => 'registrations' }
  
  match '/auth/:provider/callback' => 'authentications#create'
  delete '/logout' => 'authentications#destroy'
  #######################################################

  resources :courses, :only => [:index, :show]
  resources :users, :only => :show
  resources :schedules do
    resources :selections, {:controller => "CourseSelections",
                            :only => [:create, :update, :destroy]}
  end
  
  match "/schedules/import" => "schedules#import"
  match "/settings" => "users#edit"

end
