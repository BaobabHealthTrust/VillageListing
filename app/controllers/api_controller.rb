class ApiController < ApplicationController
	def ping
		render :text =>  "Ok"
	end

	def dashboard
		
		results = {}

		@settings = YAML.load_file("#{Rails.root}/config/dde_connection.yml")[Rails.env] rescue {}
		
		#######################  Pull new births #######################
    if secure?
      url = "https://#{(@settings["dde_username"])}:#{(@settings["dde_password"])}@#{(@settings["dde_server"])}/retrieve_births"
    else
      url = "http://#{(@settings["dde_username"])}:#{(@settings["dde_password"])}@#{(@settings["dde_server"])}/retrieve_births"
    end

    birthdate = Date.today 
   
		new_births = JSON.parse(RestClient.post(url, {"date" => birthdate}))

		####################### End puling new births ###################
			
			

		#######################  Pull new births #######################
    if secure?
      url = "https://#{(@settings["dde_username"])}:#{(@settings["dde_password"])}@#{(@settings["dde_server"])}/retrieve_births"
    else
      url = "http://#{(@settings["dde_username"])}:#{(@settings["dde_password"])}@#{(@settings["dde_server"])}/retrieve_births"
    end

    birthdate = Date.today 
   
		new_births = JSON.parse(RestClient.post(url, {"date" => birthdate}))

		####################### End puling new births ###################

		results['new_births'] = new_births

		results['new_deaths'] = new_births

		render :text => results.to_json
		
	end

	def secure?
    @settings = YAML.load_file("#{Rails.root}/config/dde_connection.yml")[Rails.env]
    secure = @settings["secure_connection"] rescue false
  end

end
