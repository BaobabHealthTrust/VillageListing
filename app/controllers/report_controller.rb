class ReportController < ApplicationController
	
	def index
		@role = session[:user]["role"]
		render :layout => false
	end
	
	def user_data_entry
		@report_title = 'User Data Entry Report'
		@user_tracker = UserTracker.all
		
		render :layout => false
	end
	
	def death_outcome
		
		@report_title = 'Zotsatira za omwalira'
		
		server_address = YAML.load_file("#{Rails.root}/config/dde_connection.yml")[Rails.env]["dde_server"] rescue (raise raise "dde_server_address not set in dde_connection.yml")
		uri = "http://#{server_address}/population_stats.json/"
		paramz = {district: session[:user]['district'], ta: session[:user]['ta'],
		          stat: 'current_death_outcomes', village: session[:user]['village']}
		
		data = RestClient.post(uri,paramz)
		
		unless data.blank?
			@stats = JSON.parse(data)
		else
			@stats = []
		end
		
		render :layout => false
	
	end
	
	def monthly_select
		@years = ['2018','2017', '2016', '2015'] # to make these dynamic
		@months = Date::MONTHNAMES
	end
	
	def bloomberg_union
		
		@report_title = 'Bloomberg Union Monthly'
		server_address = YAML.load_file("#{Rails.root}/config/dde_connection.yml")[Rails.env]["dde_server"] rescue (raise raise "dde_server_address not set in dde_connection.yml")
		uri = "http://#{server_address}/population_stats.json/"
		paramz = {district: session[:user]['district'], ta: session[:user]['ta'],
		          stat: 'bloomberg_union', month_period: params[:month_period], year: params[:year]}
		
		data = RestClient.post(uri,paramz)
		
		unless data.blank?
			@stats = JSON.parse(data)
			File.open("bloomberg_union.json","w") do |f|
				f.write(@stats)
			end
		else
			@stats = []
		end
		
		render :layout => false
	
	end
	
	def village_outcome
		
		@report_title = 'Zotsatira zonse' #Village outcome stats
		
		server_address = YAML.load_file("#{Rails.root}/config/dde_connection.yml")[Rails.env]["dde_server"] rescue (raise raise "dde_server_address not set in dde_connection.yml")
		uri = "http://#{server_address}/population_stats.json/"
		paramz = {district: session[:user]['district'], ta: session[:user]['ta'],
		          stat: 'current_village_outcomes', village: session[:user]['village']}
		data = RestClient.post(uri,paramz)
		
		unless data.blank?
			@stats = JSON.parse(data)
		else
			@stats = []
		end
		
		render :layout => false
	end
	
	def village_population_birth_year
		@report_title = "Chiwerengero cha m'mudzi/midzi"#'Village people list'
		
		server_address = YAML.load_file("#{Rails.root}/config/dde_connection.yml")[Rails.env]["dde_server"] rescue (raise raise "dde_server_address not set in dde_connection.yml")
		
		@selected_villages = []
		params[:ta]['villages'].each do |village|
			@selected_villages << village.squish.capitalize
		end
		
		uri = "http://#{server_address}/population_stats.json/"
		paramz = {district: session[:user]['district'], ta: session[:user]['ta'], stat: 'ta_population_tabulation'}
		data = RestClient.post(uri,paramz)
		
		@start_birthdate = "#{params[:person]['birth_year_start']}-#{params[:person]['birth_month_start']}-01".to_date rescue nil
		@end_birthdate = "#{params[:person]['birth_year_end']}-#{params[:person]['birth_month_end']}-01".to_date.end_of_month rescue nil
		
		if @start_birthdate.blank? || @end_birthdate.blank?
			redirect_to '/' and return
		end
		
		unless data.blank?
			@people = []
			data = JSON.parse(data)
			(data).each do |person|
				village_name = person['addresses']['current_village']
				next unless @selected_villages.include?(village_name.squish.capitalize)
				birthdate = person['birthdate'].to_date rescue nil
				next if birthdate.blank?
				next unless (birthdate >= @start_birthdate and birthdate <= @end_birthdate)
				@people << person
			end
		else
			@people = []
		end
		
		render :layout => false
	end
	
	def village_population
		
		@report_title = "Chiwerengero cha m'mudzi"#'Village people list'
		
		village = session[:user]['village']
		
		server_address = YAML.load_file("#{Rails.root}/config/dde_connection.yml")[Rails.env]["dde_server"] rescue (raise raise "dde_server_address not set in dde_connection.yml")
		uri = "http://#{server_address}/population_stats.json/"
		paramz = {district: session[:user]['district'], ta: session[:user]['ta'],
		          stat: 'current_district_ta_village', village: village}
		data = RestClient.post(uri,paramz)
		unless data.blank?
			@people = JSON.parse(data)
			File.open("mzumazi.json","w") do |f|
				f.write(data)
			end
			Kernel.system "node #{Rails.root}/json2csv.js > #{Rails.root}/#{village}.csv"
		else
			@people = []
		end
		@report_generation_path = "/village_population?run=true"
		
		render :layout => false
	end
	
	def drill_down
		@report_title = ''
		report_type = params[:report_type]
		case report_type
			when 'death_outcome'
				outcome = params[:outcome]
				@report_title = "Zotsatira za omwalira (#{outcome.gsub('_',' ').titleize})"
			when 'bloomberg_union'
				parameter = params[:parameter]
				@report_title = "Bloomberg Union (#{parameter.gsub('_',' ').titleize})"
		end
		
		village = session[:user]['village']
		server_address = YAML.load_file("#{Rails.root}/config/dde_connection.yml")[Rails.env]["dde_server"] rescue (raise raise "dde_server_address not set in dde_connection.yml")
		uri = "http://#{server_address}/population_stats.json/"
		
		if outcome
			paramz = {district: session[:user]['district'], ta: session[:user]['ta'],
			          stat: 'current_district_ta_village_outcome_cause', village: village, outcome: outcome}
		elsif parameter
			paramz = {district: session[:user]['district'], ta: session[:user]['ta'],
			          stat: 'current_district_ta_parameter', parameter: parameter, month_period: params[:month_period]}
		end

		data = RestClient.post(uri,paramz)
		
		unless data.blank?
			@people = JSON.parse(data)
		else
			@people = []
		end
		@report_generation_path = "/village_population?run=true"
		
		render :layout => false
	end
	
	def ta_population_tabulation
		@selected_villages = []
		params[:ta]['villages'].each do |village|
			@selected_villages << village.squish.capitalize
		end
		@report_title = "Chiwerengero cha T/A"#'TA villages (citizen counts)'
		@report_generation_path = []
		
		server_address = YAML.load_file("#{Rails.root}/config/dde_connection.yml")[Rails.env]["dde_server"] rescue (raise raise "dde_server_address not set in dde_connection.yml")
		uri = "http://#{server_address}/population_stats.json/"
		paramz = {district: session[:user]['district'], ta: session[:user]['ta'], stat: 'ta_population_tabulation'}
		data = RestClient.post(uri,paramz)
		
		unless data.blank?
			@stats = {}
			data = JSON.parse(data)
			(data).each do |person|
				village_name = person['addresses']['current_village']
				next unless @selected_villages.include?(village_name.squish.capitalize)
				@stats[person['addresses']['current_village']] = {} if @stats[person['addresses']['current_village']].blank?
				@stats[person['addresses']['current_village']][person['gender']] = 0 if @stats[person['addresses']['current_village']][person['gender']] .blank?
				@stats[person['addresses']['current_village']][person['gender']] += 1
			end
			@export_to_csv = true
		else
			@export_to_csv = false
			@stats = {}
		end
		render :layout => false
	end
	
	def ta_population
		
		@report_title = "Chiwerengero cha M'boma"#'TA counts'
		
		if params[:run] == 'true'
			server_address = YAML.load_file("#{Rails.root}/config/dde_connection.yml")[Rails.env]["dde_server"] rescue (raise raise "dde_server_address not set in dde_connection.yml")
			uri = "http://#{server_address}/population_stats.json/"
			paramz = {district: session[:user]['district'], stat: 'ta_population'}
			data = RestClient.post(uri,paramz)
			
			unless data.blank?
				@stats = {}
				data = JSON.parse(data)
				(data).each do |person|
					@stats[person['addresses']['current_village']] = {} if @stats[person['addresses']['current_village']].blank?
					@stats[person['addresses']['current_village']][person['gender']] = 0 if @stats[person['addresses']['current_village']][person['gender']] .blank?
					@stats[person['addresses']['current_village']][person['gender']] += 1
				end
			else
				@stats = {}
			end
		else
			@report_generation_path = "/ta_population?run=true"
			@stats = {}
		end
		render :layout => false
	end
	
	def village_population_per_ta
	
	end
	
	def village_age_groups
		
		@report_title = "Chiwerengero cha m'mudzi (pa dzaka)" #Village people count/break-down by Gender and Age groups'
		
		server_address = YAML.load_file("#{Rails.root}/config/dde_connection.yml")[Rails.env]["dde_server"] rescue (raise raise "dde_server_address not set in dde_connection.yml")
		uri = "http://#{server_address}/population_stats.json/"
		paramz = {district: session[:user]['district'], ta: session[:user]['ta'],
		          stat: 'current_district_ta_village', village: session[:user]['village']}
		data = RestClient.post(uri,paramz)
		
		@stats = {}
		unless data.blank?
			(JSON.parse(data) || []).each do |person|
				age_group = get_age_group(person)
				gender = person['gender'].blank? ? 'Unknown' : person['gender']
				@stats[age_group] = {} if @stats[age_group].blank?
				@stats[age_group][gender] = 0 if @stats[age_group][gender].blank?
				@stats[age_group][gender] += 1
			end
		end
		
		render :layout => false
	end
	
	def village_selection
		if params[:extras] == 'tornado'
			params[:report_path] = 'get_tornado_data/true'
		end
		
		paramz = {ta_name: session[:user]['ta'], user: session[:user] }
		server_address = YAML.load_file("#{Rails.root}/config/globals.yml")[Rails.env]["user_mgmt_url"] rescue (raise "set your user Mgmt URL in globals.yml")
		uri = "http://#{server_address}/demographics/villages.json/"
		data = RestClient.post(uri,paramz)
		
		unless data.blank?
			@villages = JSON.parse(data)
		else
			@villages = {}
		end
	end
	
	def village_selection_per_ta
		paramz = {district_name: session[:user]['district'], user: session[:user] }
		server_address = YAML.load_file("#{Rails.root}/config/globals.yml")[Rails.env]["user_mgmt_url"] rescue (raise "set your user Mgmt URL in globals.yml")
		uri = "http://#{server_address}/demographics/traditional_authorities.json/"
		traditional_authorities = RestClient.post(uri,paramz)
		@traditiona_authorities = JSON.parse(traditional_authorities)
	end
	
	def village_selection_per_ta_data
		server_address = YAML.load_file("#{Rails.root}/config/dde_connection.yml")[Rails.env]["dde_server"] rescue (raise raise "dde_server_address not set in dde_connection.yml")
		uri = "http://#{server_address}/population_stats.json/"
		
		@report_title = "Chiwelengero Cha M'mudzi: Pa T/A"
		@ta_name = params[:ta_name]
		@selected_villages = params[:village_names]
		@stats = {}
		@selected_villages.each do |village|
			@stats[village] = {} if @stats[village].blank?
			paramz = {district: session[:user]['district'], ta: params[:ta_name], stat: 'current_district_ta_village', village: village}
			data = RestClient.post(uri,paramz)
			
			unless data.blank?
				(JSON.parse(data) || []).each do |person|
					age_group = get_age_group_modified(person)
					gender = person['gender'].blank? ? 'Unknown' : person['gender']
					@stats[village][age_group] = {} if @stats[village][age_group].blank?
					@stats[village][age_group][gender] = 0 if @stats[village][age_group][gender].blank?
					@stats[village][age_group][gender] += 1
				end
			end
		
		end
		
		@village_name = @selected_villages.join(', ')
		
		
		render :layout => false
	end
	
	def tornado
		@selected_villages = []
		params[:ta]['villages'].each do |village|
			@selected_villages << village.squish.capitalize
		end
		@report_title = "Chiwelengero cha Akazi ndi Amuna"
		
		if params[:run] == 'true'
			server_address = YAML.load_file("#{Rails.root}/config/dde_connection.yml")[Rails.env]["dde_server"] rescue (raise raise "dde_server_address not set in dde_connection.yml")
			uri = "http://#{server_address}/population_stats.json/"
			paramz = {district: session[:user]['district'], ta: session[:user]['ta'], stat: 'ta_population_tabulation'}
			data = RestClient.post(uri,paramz)
			
			unless data.blank?
				@stats = {}
				data = JSON.parse(data)
				File.open("tornado_aug_30.json","w") do |fil|
					fil.write(RestClient.post(uri,paramz))
				end
				(data).each do |person|
					village_name = person['addresses']['current_village']
					next unless @selected_villages.include?(village_name.squish.capitalize)
					age_group = get_tornado_age_group(person)
					@stats[age_group[0]] = {} if @stats[age_group[0]].blank?
					@stats[age_group[0]][age_group[1]] = 0 if @stats[age_group[0]][age_group[1]].blank?
					@stats[age_group[0]][age_group[1]] += 1
				end
			else
				@stats = {}
			end
		else
			@report_generation_path = "/get_tornado_data/true"
			@stats = {}
		end
		
		render :layout => false
	end
	
	def village_selector
		ta_name = params[:ta_name]
		paramz = {ta_name: params[:ta_name], user: session[:user] }
		server_address = YAML.load_file("#{Rails.root}/config/globals.yml")[Rails.env]["user_mgmt_url"] rescue (raise "set your user Mgmt URL in globals.yml")
		uri = "http://#{server_address}/demographics/villages.json/"
		data = RestClient.post(uri,paramz)
		villages = JSON.parse(data)
		@villages = villages.sort
	end
	
	def render_villages
		paramz = {ta_name: params[:ta_name], user: session[:user] }
		server_address = YAML.load_file("#{Rails.root}/config/globals.yml")[Rails.env]["user_mgmt_url"] rescue (raise "set your user Mgmt URL in globals.yml")
		uri = "http://#{server_address}/demographics/villages.json/"
		data = RestClient.post(uri,paramz)
		villages = JSON.parse(data)
		render :text => "<li>" + villages.sort.join("</li><li>") + "</li>" and return
	end
	
	def get_age_group(person)
		birthdate = person['birthdate'].to_date rescue 'Unknown'
		return birthdate if birthdate == 'Unknown'
		age = get_age(person)
		return 'Unknown' if age == 'Unknown'
		if age < 5
			return 'Under 5'
		elsif (age >= 5 && age < 15)
			return '5 to < 15'
		elsif age >= 15
			return '15+'
		end
		raise "#{age} #{ (age >= 5 && age < 15) }"
	end
	
	def get_age_group_modified(person)
		birthdate = person['birthdate'].to_date rescue 'Unknown'
		return birthdate if birthdate == 'Unknown'
		age = get_age(person)
		return 'Unknown' if age == 'Unknown'
		if age < 5
			return '0-4'
		elsif (age >= 5 && age < 15)
			return '5-14'
		elsif (age >= 15 && age < 45)
			return '15-44'
		elsif (age >= 45 && age < 65)
			return '45-64'
		elsif (age >= 65)
			return '>=65'
		end
		raise "#{age} #{ (age >= 5 && age < 15) }"
	end
	
	def get_age(person, today = Date.today)
		birthdate = person['birthdate'].to_date rescue nil
		return 'Unknown' if birthdate.blank?
		
		# This code which better accounts for leap years
		patient_age = (today.year - birthdate.year) + ((today.month - birthdate.month) + ((today.day - birthdate.day) < 0 ? -1 : 0) < 0 ? -1 : 0)
		
		# If the birthdate was estimated this year, we round up the age, that way if
		# it is March and the patient says they are 25, they stay 25 (not become 24)
		birth_date = birthdate
		estimate = person['birthdate_estimated'] == true
		
		patient_age += (estimate && birth_date.month == 7 && birth_date.day == 1  &&
				today.month < birth_date.month && person['created_at'].to_date.year == today.year) ? 1 : 0
		
		return patient_age.to_i
	end
	
	def get_tornado_age_group(person)
		categories = ['0-4', '5-9', '10-14', '15-19',
		              '20-24', '25-29', '30-34', '35-39', '40-44',
		              '45-49', '50-54', '55-59', '60-64', '65-69',
		              '70-74', '75-79', '80-84', '85 + ']
		
		
		return 'Unknown' if person['gender'].blank? || person['birthdate'].blank?
		gender = person['gender']
		age = get_age(person).to_i
		if age <= 4
			cat = categories[0]
		elsif age > 4 and age <= 9
			cat = categories[1]
		elsif age > 9 and age <= 14
			cat = categories[2]
		elsif age > 14 and age <= 19
			cat = categories[3]
		elsif age > 19 and age <= 24
			cat = categories[4]
		elsif age > 24 and age <= 29
			cat = categories[5]
		elsif age > 29 and age <= 34
			cat = categories[6]
		elsif age > 34 and age <= 39
			cat = categories[7]
		elsif age > 39 and age <= 44
			cat = categories[8]
		elsif age > 44 and age <= 49
			cat = categories[9]
		elsif age > 49 and age <= 54
			cat = categories[10]
		elsif age > 54 and age <= 59
			cat = categories[11]
		elsif age > 59 and age <= 64
			cat = categories[12]
		elsif age > 64 and age <= 69
			cat = categories[13]
		elsif age > 69 and age <= 74
			cat = categories[14]
		elsif age > 74 and age <= 79
			cat = categories[15]
		elsif age > 79 and age <= 84
			cat = categories[16]
		elsif age >=  85
			cat = categories[17]
		end
		
		
		if gender == 'F' || gender == 'Female' || gender == 'Mkazi' #gender.match(/F/i)
			return ['Female', cat]
		elsif gender == 'M' || gender == 'Male' || gender == 'Mwamuna'
			return ['Male', cat]
		end
	
	end

end
