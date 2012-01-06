AcmSchedule::Application.routes.draw do
  
  root :to => "static#home"
  match "/tos" => "static#tos"
  match "/privacy" => "static#privacy"
  
  #################### Omniauth ########################
  match '/auth/:provider/callback' => 'authentications#create'
  delete '/logout' => 'authentications#destroy'
  #######################################################

  resources :courses, :only => [:index, :show]
  match "/departments/:department_id" => "courses#index"
  resources :schedules do
    resources :selections, {:controller => "CourseSelections",
                            :only => [:create, :update, :destroy]}
  end
  match "/schedules/import" => "schedules#import"

  resources :users, :only => :show
  match "/settings" => "users#edit"
  match "/friends" => "friends#index"
  
end
