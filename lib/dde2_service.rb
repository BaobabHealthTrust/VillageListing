module DDE2Service
	def self.dde_settings
		dde_connection = YAML.load_file("#{Rails.root}/config/dde_connection.yml")[Rails.env]
		dde_server = dde_connection['dde_server']
		default_username = dde_connection['default_username']
		default_password = dde_connection['default_password']
		dde_username = dde_connection['dde_username']
		dde_password = dde_connection['dde_password']
		application_name = dde_connection['application_name']
		site_code = dde_connection['site_code']
		
		return {'server': dde_server, 'default_username': default_username,
		        'default_password': default_password, 'username': dde_username,
		        'password': dde_password, 'application_name': application_name, 'site_code': site_code}
	end
	
	def self.dde_authenticate(dde)
		if dde[:username].nil?
			payload_params = {'username': dde[:default_username], 'password': dde[:default_password]}
		else
			payload_params = {'username': dde[:username], 'password': dde[:password]}
		end
		
		response = RestClient.post "#{dde[:server]}/v1/authenticate", payload_params.to_json,
		                           content_type: :json
		
		data = JSON.parse(response)['data']
		
		dde_token = data['token']
		
		File.open("#{Rails.root}/tmp/token",'w') do |token|
			token.write(dde_token)
		end
		
		return data
	end
	
	def self.get_token
		dde_token = File.open("#{Rails.root}/tmp/token", 'rb') {|token|
			token.read
		}
		
		return dde_token
	end
	
	def self.check_dde_token(token)
		dde = self.dde_settings
		response = RestClient.get "#{dde[:server]}/v1/authenticated/#{token}"
		
		return response
	end
	
	def self.add_dde_user(dde, token)
		payload_params = {'username': dde[:username], 'password': dde[:password], 'application': dde[:application_name],
		                  'site_code': dde[:site_code], 'token': token}
		response = RestClient.put"#{dde[:server]}/v1/add_user", payload_params.to_json,
		                         content_type: :json
		
		return response
	end
	
	def self.search_by_identifer(identifier, token)
		dde = self.dde_settings
		dde_target = "#{dde[:server]}/v1/search_by_identifier/#{identifier}/#{token}"
		
		response = RestClient.get(dde_target) { |response, request, result, &block|
			case response.code
				when 200
					'Success'
					return response
				when 204
					'No Content'
				when 401
					'Unauthorised'
				else
					response.return!(&block)
			end
		}
		
		return response
	end
	
	def self.search_by_name_and_gender(given_name, family_name, gender)
		token = self.get_token
		dde = self.dde_settings
		dde_target = self.dde_target('search_by_name_and_gender')
		payload_params = {'given_name': given_name, 'family_name': family_name, 'gender': gender, 'token': token}
		
		response = RestClient.post(dde_target, payload_params.to_json, content_type: :json) {
				|response, request, result, &block|
			case response.code
				when 200
					'Success'
					return response
				when 204
					'No Content'
				when 401
					'Unauthorised'
				else
					response.return!(&block)
			end
		}
		
		return response
	end
	
	def self.add_patient(dde_object)
		token = self.get_token
		dde_object = {
				'given_name': dde_object['names']['given_name'],
		        'family_name': dde_object['names']['family_name'],
				'middle_name': dde_object['names']['middle_name'],
				'gender': (dde_object['gender']=='F'?'Female':'Male'),
		        'birthdate': dde_object['birthdate'].gsub('/','-').to_date.strftime("%Y-%m-%d"),
		        'birthdate_estimated': dde_object['birthdate_estimated'],
		        'home_village': dde_object['addresses']['home_village'],
		        'home_ta': dde_object['addresses']['home_ta'],
		        'home_district': dde_object['addresses']['home_district'],
		        'token': token
		}
		dde_target = self.dde_target('add_patient')
		payload_params = dde_object
		
		response = RestClient.put(dde_target, payload_params.to_json, content_type: :json) {
				|response, request, result, &block|
			response
		}
		return response
	end
	
	def self.dde_target(path, identifier=nil, token=self.get_token)
		dde = self.dde_settings
		case path
			when 'search_by_name_and_gender'
				dde_target = "#{dde[:server]}/v1/search_by_name_and_gender"
			when 'search_by_identifer'
				dde_target = "#{dde[:server]}/v1/search_by_identifier/#{identifier}/#{token}"
			when 'add_patient'
				dde_target = "#{dde[:server]}/v1/add_patient"
		end
		return dde_target
	end
end