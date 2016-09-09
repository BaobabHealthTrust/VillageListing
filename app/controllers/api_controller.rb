class ApiController < ApplicationController
	def ping

		render :text =>  "Ok"
	end

	def dashboard
		
		results = {}
    results['births'] = {}
    results['deaths'] = {}

    connected = {}
    Dir.entries("log/lastseen").select {|f| !File.directory? f}.each do |site|
      connected[site] = File.mtime("log/lastseen/#{site}").to_s(:db)
    end

    results["online"] = connected

    @settings = YAML.load_file("#{Rails.root}/config/dde_connection.yml")[Rails.env] rescue {}
		
		#######################  Pull new births #######################
    if secure?
      url = "https://#{(@settings["dde_username"])}:#{(@settings["dde_password"])}@#{(@settings["dde_server"])}/retrieve_births"
    else
      url = "http://#{(@settings["dde_username"])}:#{(@settings["dde_password"])}@#{(@settings["dde_server"])}/retrieve_births"
    end

		new_births = JSON.parse(RestClient.post(url, {"date" => Date.today}))

    new_births.each do |birth|
      district = birth['addresses']['current_district'].downcase.gsub(/\s+/, '_').downcase
      ta = birth['addresses']['current_ta'].downcase.gsub(/\s+/, '_').downcase
      village = birth['addresses']['current_village'].downcase.gsub(/\s+/, '_').downcase

      site = "#{district}__#{ta}__#{village}"
      results['births']["#{site}"] = 0 if results['births']["#{site}"].blank?
      results['births']["#{site}"] += 1
    end
		####################### End puling new births ###################
  	render :text => results.to_json

	end

	def secure?
    @settings = YAML.load_file("#{Rails.root}/config/dde_connection.yml")[Rails.env]
    secure = @settings["secure_connection"] rescue false
  end

end
