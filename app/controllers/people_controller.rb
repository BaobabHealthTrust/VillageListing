class PeopleController < ApplicationController
	skip_before_action :verify_authenticity_token
	
	def search
	end
	
	def show
		
		session.delete(:secondary_person)
		redirect_to ("/") and return if session[:dde_object].blank?
		
		@patient_bean = formatted_dde_object
		
		@patient_bean = OpenStruct.new @patient_bean #Making the keys accessible by a dot operator
		
		# creating a tracker --------------------------------------------------------------------------
		user_tracker = UserTracker.find_by_person_tracker("#{@patient_bean.national_id}")
		
		if user_tracker.blank?
			UserTracker.create(person_tracker: @patient_bean.national_id,
			                   username: session[:user]['username'])
		else
			# skip if tracker already available and not needed to update else update
		end
	end
	
	def national_id_label
		patient_bean = formatted_dde_object
		national_id = patient_bean.national_id.downcase.gsub("-", "_")
		print_string = patient_national_id_label(patient_bean)
		send_data(print_string,:type=>"application/label; charset=utf-8", :stream=> false,
		          :filename=>"#{national_id}.lbl", :disposition => "inline")
	end
	
	def national_id_label_relation
		patient_bean = formatted_dde_object
		national_id = patient_bean.national_id.downcase.gsub("-", "_")
		print_string = patient_national_id_label_relation(patient_bean)
		send_data(print_string,:type=>"application/label; charset=utf-8", :stream=> false,
		          :filename=>"#{national_id}.lbl", :disposition => "inline")
	end
	
	def get_names
		if params[:search_str].blank?
			params[:search_str] = 'A'
		end
		
		paramz = {user: session[:user], search_str: params[:search_str], name: params[:name]}
		server_address = YAML.load_file("#{Rails.root}/config/globals.yml")[Rails.env]["user_mgmt_url"]
		uri = "http://#{server_address}/demographics/#{params[:name]}.json/"
		names = RestClient.post(uri,paramz)
		
		unless names.blank?
			@names = JSON.parse(names)
			render :text => "<li>" + @names.map{|n| n } .join("</li><li>") + "</li>" and return
		else
			@names = []
			render :text => "<li>" + @names.map{|n| n } .join("</li><li>") + "</li>" and return
		end
	
	end
	
	def patient_national_id_label(patient_bean)
		print_string = %Q(
N
q812
Q305,026
ZT
B35,170,0,1,5,15,100,N,"#{patient_bean.national_id}"
A35,30,0,2,2,2,N,"#{patient_bean.name}"
A35,76,0,2,2,2,N,"#{patient_bean.national_id} #{patient_bean.birthdate}(#{patient_bean.sex})"
A35,122,0,2,2,2,N,"#{patient_bean.home_ta}, #{patient_bean.home_village}"
P1\n)
		return print_string
	
	end
	
	def patient_national_id_label_relation(patient_bean)
		print_string = %Q(
N
q812
Q305,026
ZT
B35,170,0,1,5,15,100,N,"#{patient_bean.national_id}"
A35,30,0,2,2,2,N,"#{patient_bean.name}"
A35,76,0,2,2,2,N,"#{patient_bean.national_id} #{patient_bean.birthdate}(#{patient_bean.sex})"
A35,122,0,2,2,2,N,"#{patient_bean.home_ta}, #{patient_bean.home_village}"
P1\n)
		return print_string
	
	end
	
	def formatted_dde_object
		dde_object = session[:dde_object]
		
		national_id = dde_object["_id"]
		national_id = dde_object["national_id"] if national_id.blank?
		
		given_name = dde_object["names"]["given_name"]
		middle_name = dde_object["names"]["middle_name"]
		maiden_name = dde_object["names"]["maiden_name"]
		family_name = dde_object["names"]["family_name"]
		person_name = given_name.to_s + ' ' + family_name.to_s
		birthdate_estimated = dde_object["birthdate_estimated"]
		birthdate = dde_object["birthdate"]
		formatted_birthdate = birthdate.to_date.strftime("%d/%b/%Y") rescue birthdate
		
		current_residence = dde_object["addresses"]["current_residence"]
		current_village = dde_object["addresses"]["current_village"]
		current_ta = dde_object["addresses"]["current_ta"]
		current_district = dde_object["addresses"]["current_district"]
		
		home_village = dde_object["addresses"]["home_village"]
		home_ta = dde_object["addresses"]["home_ta"]
		home_district = dde_object["addresses"]["home_district"]
		
		gender = dde_object["gender"]
		identifiers = []
		identifiers = dde_object["patient"]["identifiers"] unless dde_object["patient"].blank?
		
		home_phone_number = dde_object["person_attributes"]["home_phone_number"]
		cell_phone_number = dde_object["person_attributes"]["cell_phone_number"]
		office_phone_number = dde_object["person_attributes"]["office_phone_number"]
		
		race = dde_object["person_attributes"]["race"]
		occupation = dde_object["person_attributes"]["occupation"]
		citizenship = dde_object["person_attributes"]["citizenship"]
		country_of_residence = dde_object["person_attributes"]["country_of_residence"]
		
		#################### Code to pull person outcome from the DDE ############################
		dde_server_address = YAML.load_file("#{Rails.root}/config/dde_connection.yml")[Rails.env]["dde_server"] rescue "raise dde_server_address not set in dde_connection.yml"
		url = "http://#{dde_server_address}/population_stats"
		outcome_paramz = {}
		outcome_paramz['stat'] = 'fetch_outcome' ; outcome_paramz['identifier'] = national_id
		result = RestClient.post(url, outcome_paramz) rescue {}
		data = JSON.parse(result) rescue {}
		
		session[:dde_object]['outcome'] = data['outcome_data']['outcome'] rescue nil
		session[:dde_object]['outcome_date'] = data['outcome_data']['outcome_date'] rescue nil
		outcome_date = session[:dde_object]['outcome_date'] ; outcome = session[:dde_object]['outcome']
		
		unless data['person'].blank?
			current_district = data['person']['addresses']['current_district']
			current_ta = data['person']['addresses']['current_ta']
			current_village = data['person']['addresses']['current_village']
		end unless data.blank?
		#################### Code to pull person outcome from the DDE (ends)############################
		unless outcome.blank?
			outcome = outcome == 'Transfer Out' ? 'Adasamuka' : 'Died'
		end
		patient_bean = {
				:national_id => national_id,
				:first_name => given_name,
				:middle_name => middle_name,
				:maiden_name => maiden_name,
				:last_name => family_name,
				:name => person_name,
				:birthdate_estimated => birthdate_estimated,
				:birthdate => formatted_birthdate,
				:current_residence => current_residence,
				:current_village => current_village,
				:current_ta => current_ta,
				:current_district => current_district,
				:home_ta => home_ta,
				:home_village => home_village,
				:home_district => home_district,
				:sex => gender,
				:identifiers => identifiers,
				:home_phone_number => home_phone_number,
				:cell_phone_number => cell_phone_number,
				:office_phone_number => office_phone_number,
				:race => race,
				:occupation => occupation,
				:citizenship => citizenship,
				:country_of_residence => country_of_residence,
				:outcome => outcome, :outcome_date => outcome_date
		}
		
		patient_bean = OpenStruct.new patient_bean #Making the keys accessible by a dot operator
		return patient_bean
	end
	
	def demographics
		redirect_to ("/") and return if session[:dde_object].blank?
		settings = YAML.load_file("#{Rails.root}/config/globals.yml")[Rails.env] rescue {}
		
		@settings = YAML.load_file("#{Rails.root}/config/dde_connection.yml")[Rails.env] rescue {}
		
		@show_middle_name = (settings["show_middle_name"] == true ? true : false) rescue false
		
		@show_maiden_name = (settings["show_maiden_name"] == true ? true : false) rescue false
		
		@show_birthyear = (settings["show_birthyear"] == true ? true : false) rescue false
		
		@show_birthmonth = (settings["show_birthmonth"] == true ? true : false) rescue false
		
		@show_birthdate = (settings["show_birthdate"] == true ? true : false) rescue false
		
		@show_age = (settings["show_age"] == true ? true : false) rescue false
		
		@show_region_of_origin = (settings["show_region_of_origin"] == true ? true : false) rescue false
		
		@show_district_of_origin = (settings["show_district_of_origin"] == true ? true : false) rescue false
		
		@show_t_a_of_origin = (settings["show_t_a_of_origin"] == true ? true : false) rescue false
		
		@show_home_village = (settings["show_home_village"] == true ? true : false) rescue false
		
		@show_current_region = (settings["show_current_region"] == true ? true : false) rescue false
		
		@show_current_district = (settings["show_current_district"] == true ? true : false) rescue false
		
		@show_current_t_a = (settings["show_current_t_a"] == true ? true : false) rescue false
		
		@show_current_village = (settings["show_current_village"] == true ? true : false) rescue false
		
		@show_current_landmark = (settings["show_current_landmark"] == true ? true : false) rescue false
		
		@show_cell_phone_number = (settings["show_cell_phone_number"] == true ? true : false) rescue false
		
		@show_office_phone_number = (settings["show_office_phone_number"] == true ? true : false) rescue false
		
		@show_home_phone_number = (settings["show_home_phone_number"] == true ? true : false) rescue false
		
		@show_occupation = (settings["show_occupation"] == true ? true : false) rescue false
		
		@show_nationality = (settings["show_nationality"] == true ? true : false) rescue false
		
		@show_country_of_residence = (settings["show_country_of_residence"] == true ? true : false) rescue false
		
		@occupations = ['','Driver','Housewife','Messenger','Business','Farmer','Salesperson','Teacher',
		                'Student','Security guard','Domestic worker', 'Police','Office worker',
		                'Preschool child','Mechanic','Prisoner','Craftsman','Healthcare Worker','Soldier'].sort.concat(["Other","Unknown"])
		
		@patient_bean = formatted_dde_object
	end
	
	def edit_demographics
		@patient_bean = formatted_dde_object
		@field = params[:field]
	end
	
	def update_demographics
		
		patient_bean = formatted_dde_object
		@settings = YAML.load_file("#{Rails.root}/config/dde_connection.yml")[Rails.env] rescue {}
		
		dob = (patient_bean.birthdate.to_date.strftime("%Y-%m-%d") rescue nil)
		estimate = patient_bean.birthdate_estimated == true ? true : false
		
		if !(params[:person][:birth_month] rescue nil).blank? and (params[:person][:birth_month] rescue nil).to_s.downcase == "unknown"
			dob = "#{params[:person][:birth_year]}-07-01"
			dob = Date.parse(dob).strftime("??/???/%Y")
			estimate = true
		end
		
		if !(params[:person][:birth_day] rescue nil).blank? and (params[:person][:birth_month] rescue nil).to_s.downcase == "unknown"
			dob = "#{params[:person][:birth_year]}-#{"%02d" % params[:person][:birth_month].to_i}-15"
			dob = Date.parse(dob).strftime("??/%b/%Y")
			estimate = true
		end
		
		if !(params[:person][:birth_month] rescue nil).blank? and (params[:person][:birth_month] rescue nil).to_s.downcase != "unknown" and !(params[:person][:birth_day] rescue nil).blank? and (params[:person][:birth_day] rescue nil).to_s.downcase != "unknown" and !(params[:person][:birth_year] rescue nil).blank? and (params[:person][:birth_year] rescue nil).to_s.downcase != "unknown"
			dob = "#{params[:person][:birth_year]}-#{"%02d" % params[:person][:birth_month].to_i}-#{"%02d" % params[:person][:birth_day].to_i}"
			dob = Date.parse(dob).strftime("%d/%b/%Y")
			estimate = false
		end
		
		
		if (params[:person][:attributes]["citizenship"] == "Other" rescue false)
			params[:person][:attributes]["citizenship"] = params[:person][:attributes]["race"]
		end
		
		person = {
				"national_id" => patient_bean.national_id,
				"application" => "#{@settings["application_name"]}",
				"site_code" => "#{@settings["site_code"]}",
				"return_path" => "http://#{request.host_with_port}/process_result",
				"patient_id" => (nil),
				"patient_update" => true,
				"names" =>
						{
								"family_name" => (!(params[:person][:names][:family_name] rescue nil).blank? ? (params[:person][:names][:family_name] rescue nil) : (patient_bean.last_name rescue nil)),
								"given_name" => (!(params[:person][:names][:given_name] rescue nil).blank? ? (params[:person][:names][:given_name] rescue nil) : (patient_bean.first_name rescue nil)),
								"middle_name" => (!(params[:person][:names][:middle_name] rescue nil).blank? ? (params[:person][:names][:middle_name] rescue nil) : (patient_bean.middle_name rescue nil)),
								"maiden_name" => (!(params[:person][:names][:family_name2] rescue nil).blank? ? (params[:person][:names][:family_name2] rescue nil) : (patient_bean.maiden_name rescue nil))
						},
				"gender" => (!params["gender"].blank? ? params["gender"] : (patient_bean.sex rescue nil)),
				"person_attributes" => {
						"occupation" => (!(params[:person][:attributes][:occupation] rescue nil).blank? ? (params[:person][:attributes][:occupation] rescue nil) :
								patient_bean.occupation),
						
						"cell_phone_number" => (!(params[:person][:attributes][:cell_phone_number] rescue nil).blank? ? (params[:person][:attributes][:cell_phone_number] rescue nil) :
								patient_bean.cell_phone_number),
						
						"home_phone_number" => (!(params[:person][:attributes][:home_phone_number] rescue nil).blank? ? (params[:person][:attributes][:home_phone_number] rescue nil) :
								patient_bean.home_phone_number),
						
						"office_phone_number" => (!(params[:person][:attributes][:office_phone_number] rescue nil).blank? ? (params[:person][:attributes][:office_phone_number] rescue nil) :
								patient_bean.office_phone_number),
						
						"country_of_residence" => (!(params[:person][:attributes][:country_of_residence] rescue nil).blank? ? (params[:person][:attributes][:country_of_residence] rescue nil) :
								patient_bean.country_of_residence),
						
						"citizenship" => (!(params[:person][:attributes][:citizenship] rescue nil).blank? ? (params[:person][:attributes][:citizenship] rescue nil) :
								patient_bean.citizenship)
				},
				"birthdate" => dob,
				"patient" => {
						"identifiers" => patient_bean.identifiers
				},
				"birthdate_estimated" => estimate,
				"addresses" => {
						"current_residence" => (!(params[:person][:addresses][:address1]  rescue nil).blank? ? (params[:person][:addresses][:address1] rescue nil) : patient_bean.current_residence),
						"current_village" => (!(params[:person][:addresses][:city_village] rescue nil).blank? ? (params[:person][:addresses][:city_village] rescue nil) : patient_bean.current_village),
						"current_ta" => (!(params[:person][:addresses][:township_division] rescue nil).blank? ? (params[:person][:addresses][:township_division] rescue nil) : patient_bean.current_ta),
						"current_district" => (!(params[:person][:addresses][:state_province] rescue nil).blank? ? (params[:person][:addresses][:state_province] rescue nil) : patient_bean.current_district),
						"home_village" => (!(params[:person][:addresses][:neighborhood_cell] rescue nil).blank? ? (params[:person][:addresses][:neighborhood_cell] rescue nil) : patient_bean.home_village),
						"home_ta" => (!(params[:person][:addresses][:county_district] rescue nil).blank? ? (params[:person][:addresses][:county_district] rescue nil) : patient_bean.home_ta),
						"home_district" => (!(params[:person][:addresses][:address2] rescue nil).blank? ? (params[:person][:addresses][:address2] rescue nil) : patient_bean.home_district)
				}
		}
		
		if secure?
			url = "https://#{@settings["dde_username"]}:#{@settings["dde_password"]}@#{@settings["dde_server"]}/process_confirmation"
		else
			url = "http://#{@settings["dde_username"]}:#{@settings["dde_password"]}@#{@settings["dde_server"]}/process_confirmation"
		end
		
		result = RestClient.post(url, {:person => person, :target => "update"})
		
		json = JSON.parse(result) rescue {}
		
		if (json["patient"]["identifiers"] rescue "").class.to_s.downcase == "hash"
			
			tmp = json["patient"]["identifiers"]
			
			json["patient"]["identifiers"] = []
			
			tmp.each do |key, value|
				
				json["patient"]["identifiers"] << {key => value}
			
			end
		
		end
		
		session[:dde_object] = json
		
		redirect_to "/demographics" and return
	
	end
	
	def secure?
		@settings = YAML.load_file("#{Rails.root}/config/dde_connection.yml")[Rails.env]
		secure = @settings["secure_connection"] rescue false
	end
	
	def outcome
		
		@patient_bean = formatted_dde_object
		
		if request.post?
			
			dde_server_address = YAML.load_file("#{Rails.root}/config/dde_connection.yml")[Rails.env]["dde_server"] rescue (raise raise "dde_server_address not set in dde_connection.yml")
			url = "http://#{dde_server_address}/population_stats"
			outcome_paramz = {}
			
			if params[:outcome]['outcome'].match(/adasamuka/i)
				location_paramz = {district: params[:person]['addresses']['address2'],
				                   ta: params[:person]['addresses']['county_district'],
				                   village: params[:person]['addresses']['neighborhood_cell']
				}
				cause_of_death = nil
				params[:outcome]['outcome'] = "Transfer Out"
			else
				location_paramz = nil
				cause_of_death = params[:cause_of_death]
				params[:outcome]['outcome'] = "Died"
			end
			
			
			outcome_paramz['outcome'] = {outcome: params[:outcome]['outcome'],
			                             year: params[:outcome_year],month: params[:outcome_month],
			                             day: params[:outcome_day], transfering_location: location_paramz,
			                             cause_of_death: cause_of_death
			}
			
			outcome_paramz['stat'] = 'update_outcome' ; outcome_paramz['identifier'] = params[:person]['identifier']
			result = RestClient.post(url, outcome_paramz)
			redirect_to '/people'
		end
	end

end
