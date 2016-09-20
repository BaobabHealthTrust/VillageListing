class ApiController < ApplicationController
	def ping

		render :text =>  "Ok"
	end

	def dashboard
		
		results = {}
    results['births'] = {}
    results['deaths'] = {}
    results['counts'] = {}


    connected = {}
    news_app_connected = {}
    Dir.entries("log/lastseen").select {|f| !File.directory? f}.each do |site|
      connected[site] = File.mtime("log/lastseen/#{site}").to_s(:db)
    end
    results["online"] = connected

    Dir.entries("../lastseennews").select {|f| !File.directory? f}.each do |site|
      s = site.split(/\@/).last rescue nil
      next if s.blank?
      date = File.read("../lastseennews/#{site}") rescue nil
      next if date.blank?
      news_app_connected[s] = date
    end
    results["news_online"] = news_app_connected

    @settings = YAML.load_file("#{Rails.root}/config/dde_connection.yml")[Rails.env] rescue {}
		
		#######################  Pull new births #######################
    if secure?
      url = "https://#{(@settings["dde_username"])}:#{(@settings["dde_password"])}@#{(@settings["dde_server"])}/retrieve_births_month"
    else
      url = "http://#{(@settings["dde_username"])}:#{(@settings["dde_password"])}@#{(@settings["dde_server"])}/retrieve_births_month"
    end

		new_births = JSON.parse(RestClient.post(url, {"start_date" => (Date.today - 1.month).to_s,
                                                  "end_date" => Date.today.to_s}))
    new_births.each do |birth|
      next if birth['created_at'].to_date != Date.today
      district = birth['addresses']['current_district'].downcase.gsub(/\s+/, '_').downcase
      ta = birth['addresses']['current_ta'].downcase.gsub(/\s+/, '_').downcase
      village = birth['addresses']['current_village'].downcase.gsub(/\s+/, '_').downcase

      site = "#{district}__#{ta}__#{village}"
      results['births']["#{site}"] = 0 if results['births']["#{site}"].blank?
      results['births']["#{site}"] += 1
    end
		####################### End puling new deaths ###################

    #######################  Pull new deaths #######################
    if secure?
      url = "https://#{(@settings["dde_username"])}:#{(@settings["dde_password"])}@#{(@settings["dde_server"])}/retrieve_deaths"
    else
      url = "http://#{(@settings["dde_username"])}:#{(@settings["dde_password"])}@#{(@settings["dde_server"])}/retrieve_deaths"
    end

    new_deaths = JSON.parse(RestClient.post(url, {"start_date" => (Date.today - 1.month).to_s,
                                                  "end_date" => Date.today.to_s}))
    new_deaths.each do |death|
      district = death['addresses']['current_district'].downcase.gsub(/\s+/, '_').downcase
      ta = death['addresses']['current_ta'].downcase.gsub(/\s+/, '_').downcase
      village = death['addresses']['current_village'].downcase.gsub(/\s+/, '_').downcase

      site = "#{district}__#{ta}__#{village}"
      results['deaths']["#{site}"] = 0 if results['deaths']["#{site}"].blank?
      results['deaths']["#{site}"] += 1
    end
    ####################### End puling new deaths ###################

    #######################  Pull Village Counts #######################
    if secure?
      url = "https://#{(@settings["dde_username"])}:#{(@settings["dde_password"])}@#{(@settings["dde_server"])}/village_counts"
    else
      url = "http://#{(@settings["dde_username"])}:#{(@settings["dde_password"])}@#{(@settings["dde_server"])}/village_counts"
    end

    villages = Dir.entries("log/lastseen").select {|f| !File.directory? f}

    counts = JSON.parse(RestClient.post(url, {"villages" => villages}))

    counts.each do |site, count|
      results['counts']["#{site}"] = count
    end
    ####################### End Counts ##################

  	render :text => results.to_json

	end

	def secure?
    @settings = YAML.load_file("#{Rails.root}/config/dde_connection.yml")[Rails.env]
    secure = @settings["secure_connection"] rescue false
  end

end
