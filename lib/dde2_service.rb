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
		payload_params = {'username': dde[:default_username], 'password': dde[:default_password]}
		response = RestClient.post "#{dde[:server]}/v1/authenticate", payload_params.to_json,
		                           content_type: :json
		
		data = JSON.parse(response)['data']
		
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
		
		data = JSON.parse(response)['data']
		
		dde_token = data['token']
		
		File.open("#{Rails.root}/tmp/token",'w') do |token|
			token.write(dde_token)
		end
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
		dde_target = "#{dde[:server]}/v1/search_by_name_and_gender"
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
	
	
end