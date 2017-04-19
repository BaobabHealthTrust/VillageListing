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
	end
	
	def secure?
		@settings = YAML.load_file("#{Rails.root}/config/dde_connection.yml")[Rails.env]
		secure = @settings["secure_connection"] rescue false
	end
	
	def query
		settings = YAML.load_file("#{Rails.root}/config/application.yml") rescue {}
		news_app_url = settings["#{Rails.env}"]["news.app.url"]
		ip_address = request.remote_ip
		query_ip_address = news_app_url
		query_news_path = "/api/news_feed?ip_address=" + ip_address
		path = query_ip_address + query_news_path
		result = RestClient.get('http://localhost:8000/api/news_feed?ip_address=127.0.0.1')
		json = JSON.parse(result)
		json["ip_address"] = ip_address
		render :text => json.to_json
	end
	
	def log
		settings = YAML.load_file("#{Rails.root}/config/application.yml") rescue {}
		news_app_url = settings["#{Rails.env}"]["news.app.url"]
		ip_address = request.remote_ip
		query_ip_address = news_app_url
		query_news_path = "/api/log?news_id=" + params["news_id"] + "&category=" + params["category"] + "&ip_address=" + ip_address
		path = query_ip_address + query_news_path
		result = RestClient.get(path)
		render :text => result.to_json
	end

end
