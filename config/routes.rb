AcmSchedule::Application.routes.draw do
  devise_for :users, :path_names => { :sign_in => 'login', 
                                      :sign_out => 'logout', 
                                      :registration => 'register' },
                     :controllers => { :registrations => 'registrations' }
  
  # http://stackoverflow.com/questions/5531263/
  #   omniauth-doesnt-work-with-route-globbing-in-rails3
  #match '/auth/:provider' => 'omniauth#passthru'
  
  match '/auth/:provider/callback' => 'authentications#create'
  delete '/logout' => 'authentications#destroy'

  get "home/index"

  resources :courses, :only => [:index, :show]
  #resource :sessions

  resources :schedules do
    resources :selections, {:controller => "CourseSelections",
                            :only => [:create, :update, :destroy]}
  end
  
  match "/schedules/import" => "schedules#import"

  root :to => "static#home"

  #match "/auth/:provider/callback" => "sessions#show"
  #match "/auth/failure" => "sessions#bounce"
  match "/main" => "home#main"

  match "/tos" => "static#tos"
  match "/privacy" => "static#privacy"

end
