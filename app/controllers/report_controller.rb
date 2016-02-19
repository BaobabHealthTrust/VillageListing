class ReportController < ApplicationController
  
  def index
    render :layout => false
  end

  def village_population
    
    @report_title = 'Village people list'

    if params[:run] == 'true'
      server_address = '127.0.0.1:3002' #YAML.load_file("#{Rails.root}/config/globals.yml")[Rails.env]["user_mgmt_url"] rescue (raise "set your user Mgmt URL in globals.yml")
      uri = "http://#{server_address}/population_stats.json/"
      #paramz = {district: 'Lilongwe',ta: 'Mtema', village: 'Kanyoza', stat: 'current_district_ta_village'}
      paramz = {district: session[:user]['district'], ta: session[:user]['ta'], 
                stat: 'current_district_ta_village', village: session[:user]['village']}
      data = RestClient.post(uri,paramz)

      unless data.blank?
        @people = JSON.parse(data)
      else
        @people = []
      end
    else
      @report_generation_path = "/village_population?run=true"
      @people = []
    end
    
    render :layout => false
  end

  def ta_population_tabulation
    
    @report_title = 'TA villages (citizen counts)'

    if params[:run] == 'true'
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
    else
      @report_generation_path = "/ta_population_tabulation?run=true"
      @stats = {}
    end
    render :layout => false
  end

  def ta_population
    
    @report_title = 'TA counts'

    if params[:run] == 'true'
      server_address = '127.0.0.1:3002' #YAML.load_file("#{Rails.root}/config/globals.yml")[Rails.env]["user_mgmt_url"] rescue (raise "set your user Mgmt URL in globals.yml")
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

  def village_age_groups
    
    @report_title = 'Village people count/break-down by Gender and Age groups'

    if params[:run] == 'true'
      server_address = '127.0.0.1:3002' #YAML.load_file("#{Rails.root}/config/globals.yml")[Rails.env]["user_mgmt_url"] rescue (raise "set your user Mgmt URL in globals.yml")
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
    else
      @report_generation_path = "/village_age_groups?run=true"
      @stats = {}
    end
    
    render :layout => false
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
  end


end
