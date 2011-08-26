AcmSchedule::Application.routes.draw do
  get "home/index"

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
  
  match "/friends/:id" => "friends#show"
  match "/friends" => "friends#index"
  resource :friends, :courses, :sessions

  resource :schedules do
    get 'import', :on => :member
  end
  
  match "/schedules/import" => "schedules#import"
	match "/schedules/get_friends_in_course" => "schedules#get_friends_in_course"
  match "/schedules/add-course" => "schedules#add_course"
  match "/schedules/:id" => "schedules#show"

  root :to => "home#index"

  match "/auth/:provider/callback" => "sessions#show"
  match "/main" => "home#main"

  match "/tos" => "static#tos"
  match "/privacy" => "static#privacy"
  match "/invalid_user" => "static#invalid_user"

  match "/beta" => "home#index"
end
