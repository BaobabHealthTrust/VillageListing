class HomeController < ApplicationController
  def index

    session.delete(:dde_object) unless session[:dde_object].blank?

    @settings = YAML.load_file("#{Rails.root}/config/dde_connection.yml")[Rails.env] rescue {}

    if secure?
      url = "https://#{(@settings["dde_username"])}:#{(@settings["dde_password"])}@#{(@settings["dde_server"])}/retrieve_births_month"
    else
      url = "http://#{(@settings["dde_username"])}:#{(@settings["dde_password"])}@#{(@settings["dde_server"])}/retrieve_births_month"
    end

    @new_births = JSON.parse(RestClient.post(url, {"start_date" => (Date.today - 30.days).to_s,
                                                   "end_date" => Date.today.to_s})).collect{|r|
      r['_id'] if r['created_at'].to_date == Date.today
    }.compact rescue {}

    session[:new_births] = @new_births.count rescue 0
    render :layout => false
  end

  def show_new_births
    if secure?
      url = "https://#{(@settings["dde_username"])}:#{(@settings["dde_password"])}@#{(@settings["dde_server"])}/retrieve_births_month"
    else
      url = "http://#{(@settings["dde_username"])}:#{(@settings["dde_password"])}@#{(@settings["dde_server"])}/retrieve_births_month"
    end

    @new_births = JSON.parse(RestClient.post(url, {"start_date" => (Date.today - 30.days).to_s,
                                                   "end_date" => Date.today.to_s}))
	File.open('births.json','w') do |file|
		file.write(@new_births)
	end
	File.open('jul_parsed16.json','w') do |ff|
		ff.write(RestClient.post(url, {"start_date" => '2016-07-1', "end_date" => '2016-07-31'}))
	end
  end
  
  def secure?
    @settings = YAML.load_file("#{Rails.root}/config/dde_connection.yml")[Rails.env]
    secure = @settings["secure_connection"] rescue false
  end
  
end
