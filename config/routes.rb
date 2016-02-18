Rails.application.routes.draw do
  

  ##################### people ######################
  get 'people/new'
  get 'people/search_results'
  get 'people/search'
  get 'people/show'
  ##################### people end ######################

  
  ##################### home ######################
  get '/' => 'home#index'
  ##################### home end ######################



  ##################### user ######################
  get '/admin' => 'user#index'
  get '/login' => 'user#login'
  post '/login' => 'user#login'
  get '/logout' => 'user#logout'
  get 'user/new' 
  post 'user/create' 
  get 'user/list'

  get 'user/username' 
  get 'user/first_name' 
  get 'user/last_name' 
  ##################### user end ######################

  ##################### report ######################
  get 'report/index'
  get '/ta_population' => 'report#ta_population'
  get '/village_population' => 'report#village_population'
  get '/ta_population_tabulation' => 'report#ta_population_tabulation'
  ##################### report end ######################


  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
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

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

 # ------------------------------- INSTALLATION GENERATED ----------------------------------------------------
  #map.duplicates  '/duplicates', :controller => 'dde', :action => 'duplicates'
  get '/dde/duplicates'
  get'/duplicates' => 'dde#duplicates'
  post'/duplicates' => 'dde#duplicates'

  #map.dde_search_by_name  '/dde_search_by_name', :controller => 'dde', :action => 'search_by_name'
  get '/dde/search_by_name'
  get'/dde_search_by_name' => 'dde#search_by_name'
  post'/dde_search_by_name' => 'dde#search_by_name'

  get '/dde/search'
  get '/dde/district'
  get '/dde/traditional_authority'
  get '/dde/district_villages'
  get '/dde/village'
  post '/dde/send_to_dde'
  post '/dde/ajax_process_data'
  post '/dde/process_confirmation'
  post '/dde/process_result'
  #map.dde_search_by_id  '/dde_search_by_id', :controller => 'dde', :action => 'search_by_id'
  get'/dde_search_by_id' => 'dde#search_by_id'
  post'/dde_search_by_id' => 'dde#search_by_id'

  get "/dde/find_by_national_id"
  #map.push_merge  '/push_merge', :controller => 'dde', :action => 'push_merge'
  get 'dde/push_merge'
  get'/push_merge' => 'dde#push_merge'
  post'/push_merge' => 'dde#push_merge'

  #map.process_result '/process_result', :controller => 'dde', :action => 'process_result'
  get'/process_result' => 'dde#process_result'
  post'/process_result' => 'dde#process_result'

  #map.process_data '/process_data/:id', :controller => 'dde', :action => 'process_data'
  get'/process_data/:id' => 'dde#process_data'
  post'/process_data/:id' => 'dde#process_data'

  post '/dde/process_scan_data'
  #map.search '/search', :controller => 'dde', :action => 'search_name'
  get '/dde/search_name'
  get'/search' => 'dde#search_name'
  post'/search' => 'dde#search_name'

  #map.new_patient '/new_patient', :controller => 'dde', :action => 'new_patient'
  get '/dde/new_patient'
  get'/new_patient' => 'dde#new_patient'
  post'/new_patient' => 'dde#new_patient'

  #map.ajax_process_data '/ajax_process_data', :controller => 'dde', :action => {'ajax_process_data' => [:post]}
  get'/ajax_process_data' => 'dde#ajax_process_data'
  post'/ajax_process_data' => 'dde#ajax_process_data'

  #map.process_confirmation '/process_confirmation', :controller => 'dde', :action => {'process_confirmation' => [:post]}
  get'/process_confirmation' => 'dde#process_confirmation'
  post'/process_confirmation' => 'dde#process_confirmation'

  #map.patient_not_found '/patient_not_found/:id', :controller => 'dde', :action => 'patient_not_found'
  get '/dde/patient_not_found'
  get'/patient_not_found/:id' => 'dde#patient_not_found'
  post'/patient_not_found/:id' => 'dde#patient_not_found'

  #map.ajax_search '/ajax_search', :controller => 'dde', :action => 'ajax_search'
  get'/ajax_search' => 'dde#ajax_search'
  post'/ajax_search' => 'dde#ajax_search'

  #map.edit_demographics '/patients/edit_demographics', :controller => 'dde', :action => 'edit_patient'
  get '/dde/edit_patient'
  get'/patients/edit_demographics' => 'dde#edit_patient'
  post'/patients/edit_demographics' => 'dde#edit_patient'

  #map.demographics '/people/demographics/:id', :controller => 'dde', :action => 'edit_patient'
  get '/dde/edit_patient'
  get'/people/demographics/:id' => 'dde#edit_patient'
  post'/people/demographics/:id' => 'dde#edit_patient'
 
  #map.demographics '/patients/demographics/:id', :controller => 'dde', :action => 'edit_patient'
  get '/dde/edit_patient'
  get'/patients/demographics/:id' => 'dde#edit_patient'
  post'/patients/demographics/:id' => 'dde#edit_patient'

  # ------------------------------- END OF INSTALLATION GENERATED ----------------------------------------------
  root 'home#index'
end
