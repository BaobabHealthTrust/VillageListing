Rails.application.routes.draw do
	
  get 'main/index'

	##################### people ######################
	get 'people/new'
	get 'people/search_results'
	get 'people/search'
	get 'people/show'
	get 'people/get_names'
	get '/outcomes' => 'people#outcome'
	post '/outcomes' => 'people#outcome'
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
	get '/portal' => 'user#portal'
	
	get 'user/edit/:username' => 'user#edit'
	get 'change_password/:username' => 'user#change_password'
	post 'user/change_password'
	post 'user/update'
	##################### user end ######################
	
	##################### report ######################
	get 'report/index'
	get '/ta_population' => 'report#ta_population'
	get '/village_population' => 'report#village_population'
	get 'village_selection/:report_path'=> 'report#village_selection'
	get '/village_age_groups' => 'report#village_age_groups'
	post '/ta_population_tabulation' => 'report#ta_population_tabulation'
	get '/village_outcomes' => 'report#village_outcome'
	get '/death_outcomes' => 'report#death_outcome'
	post '/village_population_birth_year' => 'report#village_population_birth_year'
	get '/report/village_population_per_ta'
	post '/report/village_population_per_ta'
	get '/report/village_selection_per_ta'
	post '/report/village_selection_per_ta'
	get '/report/render_villages'
	post '/report/render_villages'
	get '/report/village_selection_per_ta_data'
	post '/report/village_selection_per_ta_data'
	get '/report/village_selector'
	post '/report/village_selector'
	
	get '/tornado' => 'report#tornado'
	post '/tornado' => 'report#tornado'
	get 'get_tornado_data/:run' => 'report#tornado'
	post 'get_tornado_data/:run' => 'report#tornado'
	
	get '/drill_down/:report_type' => 'report#drill_down'
	post '/drill_down/:report_type' => 'report#drill_down'
	##################### report end ######################
	
	get '/query', :controller => 'home', :action => 'query'
	
	get '/log', :controller => 'home', :action => 'log'
	
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
	get '/dde/search_relation'
	get '/search_relation' => 'dde#search_relation'
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
	
	get '/people/edit_demographics'
	post '/people/update_demographics'
	#map.new_patient '/new_patient', :controller => 'dde', :action => 'new_patient'
	get '/dde/new_patient'
	get'/new_patient' => 'dde#new_patient'
	post'/new_patient' => 'dde#new_patient'
	
	get'/new_relation' => 'dde#new_relation'
	post'/new_relation' => 'dde#new_relation'
	get '/dde/create_new_relationship'
	post '/dde/create_new_relationship'
	
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
	
	get '/people/national_id_label'
	get'/national_id_label' => 'people#national_id_label'
	get'/people' => 'people#show'
	get'/demographics' => 'people#demographics'
	
	post '/dde/send_to_dde_relation'
	post '/dde/process_result_relation'
	
	get '/dde/create_relation'
	post '/dde/create_relation'
	
	get '/dde/select_relationship_type'
	post '/dde/select_relationship_type'
	get '/select_relationship_type' => 'dde#select_relationship_type'
	get'/retrieve_relations' => 'dde#retrieve_relations'
	
	#national_id_label_relation
	get '/national_id_label_relation' => 'dde#national_id_label_relation'
	post '/national_id_label_relation' => 'dde#national_id_label_relation'
	
	
	#process_confirmation_relation
	get '/process_confirmation_relation' => 'dde#process_confirmation_relation'
	get '/dde/process_confirmation_relation'
	post '/process_confirmation_relation' => 'dde#process_confirmation_relation'
	post '/dde/process_confirmation_relation'
	
	#search_relation_menu
	get '/search_relation_menu' => 'dde#search_relation_menu'
	post '/search_relation_menu' => 'dde#search_relation_menu'
	
	#select_relation_search_type
	get '/dde/select_relation_search_type'
	post '/dde/select_relation_search_type'
	
	#search_relation_by_national_id
	get '/search_relation_by_national_id' => 'dde#search_relation_by_national_id'
	post '/search_relation_by_national_id' => 'dde#search_relation_by_national_id'
	
	#process_scan_data_relation
	get '/dde/process_scan_data_relation'
	post '/dde/process_scan_data_relation'
	
	#retrieve_parents_details
	get '/retrieve_parents_details' => 'dde#retrieve_parents_details'
	post '/retrieve_parents_details' => 'dde#retrieve_parents_details'
	
	#show_new_births
	get '/show_new_births' => 'home#show_new_births'
	post '/show_new_births' => 'home#show_new_births'
	# ------------------------------- END OF INSTALLATION GENERATED ----------------------------------------------
	
    # ---- Based on Rspec tests -----
    get 'dde_authenticate' => 'dde#dde_authenticate'
    # --------------------------------
	
	#APIs
	
	get "/api/ping"
	get "/api/dashboard"
	
	#End of APIs
	root 'home#index'
end
