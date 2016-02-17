class ReportController < ApplicationController
  
  def index
    render :layout => false
  end

  def village_population
    server_address = '127.0.0.1:3002' #YAML.load_file("#{Rails.root}/config/globals.yml")[Rails.env]["user_mgmt_url"] rescue (raise "set your user Mgmt URL in globals.yml")
    uri = "http://#{server_address}/population_stats.json/"
    paramz = {district: 'Lilongwe',ta: 'Mtema', village: 'Kanyoza', stat: 'current_district_ta_village'}
    #paramz = {district: session[:user]['district'], ta: session[:user]['ta'], village: session[:user]['village']}
    data = RestClient.post(uri,paramz)

    unless data.blank?
      @people = JSON.parse(data)
    else
      @people = []
    end

=begin
    @districts = []
    server_address = '127.0.0.1:3001' #YAML.load_file("#{Rails.root}/config/globals.yml")[Rails.env]["user_mgmt_url"] rescue (raise "set your user Mgmt URL in globals.yml")
    uri = "http://#{server_address}/demographics/districts.json/"
    data = RestClient.post(uri,{region: 'Central',user: session[:user]})
    unless data.blank?
      districts = JSON.parse(data)
      (districts || []).each do |d|
        @districts << d
      end
    end

    data = RestClient.post(uri,{region: 'Southern',user: session[:user]})
    unless data.blank?
      districts = JSON.parse(data)
      (districts || []).each do |d|
        @districts << d
      end
    end

    data = RestClient.post(uri,{region: 'Northern',user: session[:user]})
    unless data.blank?
      districts = JSON.parse(data)
      (districts || []).each do |d|
        @districts << d
      end
    end
=end
    render :layout => false
  end

  def ta_population_tabulation
    server_address = '127.0.0.1:3002' #YAML.load_file("#{Rails.root}/config/globals.yml")[Rails.env]["user_mgmt_url"] rescue (raise "set your user Mgmt URL in globals.yml")
    uri = "http://#{server_address}/population_stats.json/"
    paramz = {district: session[:user]['district'], ta: session[:user]['ta'], stat: 'ta_population_tabulation'}
    #paramz = {district: session[:user]['district'], ta: session[:user]['ta'], village: session[:user]['village']}
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

    render :layout => false
  end

end
