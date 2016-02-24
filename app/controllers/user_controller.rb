class UserController < ApplicationController
  def login
    if request.post?
      server_address = YAML.load_file("#{Rails.root}/config/globals.yml")[Rails.env]["user_mgmt_url"] rescue (raise "set your user Mgmt URL in globals.yml")
      uri = "http://#{server_address}/remote_login.json/"
      user = JSON.parse(RestClient.post(uri,params))

      unless user.blank?
        session[:user] = user
        redirect_to '/' and return
      end
    end
  end

  def portal
    @new_app_path = '/'
    render :layout => false
  end

  def logout
    reset_session
    redirect_to '/portal' and return
  end

  def index
    render :layout => false
  end

  def username
    param = {user: session[:user], search_string: params[:search_string]}
    search("username", param)
  end

  def first_name
    param = {user: session[:user],search_string: params[:search_string]}
    search("first_name", param)
  end

  def last_name
    param = {user: session[:user],search_string: params[:search_string]}
    search("last_name", param)
  end

  def create
    param = {user: session[:user], new_user: params[:user]}
    server_address = YAML.load_file("#{Rails.root}/config/globals.yml")[Rails.env]["user_mgmt_url"] rescue (raise "set your user Mgmt URL in globals.yml")
    uri = "http://#{server_address}/remote_create_user.json/"
    user = RestClient.post(uri,param)
    if user.blank?
      redirect_to '/user/new' and return
    else
      redirect_to '/user/list' and return
    end
  end

  private

  def search(field_name, params)
    
    server_address = YAML.load_file("#{Rails.root}/config/globals.yml")[Rails.env]["user_mgmt_url"] rescue (raise "set your user Mgmt URL in globals.yml")

    case field_name
      when 'username'
        uri = "http://#{server_address}/get_usernames.json/"
        data = RestClient.post(uri,params)
        unless data.blank?
          data = JSON.parse(data)
          render :text => "<li>" + data.map{|n| n } .join("</li><li>") + "</li>" and return
        end
      when 'first_name'
        uri = "http://#{server_address}/get_first_names.json/"
        data = RestClient.post(uri,params)
        unless data.blank?
          data = JSON.parse(data)
          render :text => "<li>" + data.map{|n| n } .join("</li><li>") + "</li>" and return
        end
      when 'last_name'
        uri = "http://#{server_address}/get_last_names.json/"
        data = RestClient.post(uri,params)
        unless data.blank?
          data = JSON.parse(data)
          render :text => "<li>" + data.map{|n| n } .join("</li><li>") + "</li>" and return
        end
    end
    
    render :text => [].to_json
  end

end
