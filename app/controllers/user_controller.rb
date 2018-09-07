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
    settings = YAML.load_file("#{Rails.root}/config/application.yml") rescue {}
    @new_app_path = settings["#{Rails.env}"]["news.app.reader.url"]

    if settings["#{Rails.env}"]['app_gateway'] == true
      return_url = settings['app_gateway_settings']['app_gateway_url']
      redirect_to return_url and return
    else
      render :layout => false
    end
  end

  def logout
    reset_session
    redirect_to '/portal' and return
  end

  def index
    render :layout => false
  end

  def list
    @users = []
    paramz = {user: session[:user]}
    server_address = YAML.load_file("#{Rails.root}/config/globals.yml")[Rails.env]["user_mgmt_url"] rescue (raise "set your user Mgmt URL in globals.yml")
    uri = "http://#{server_address}/user_list.json/"
    users = RestClient.post(uri,paramz)
    unless users.blank?
      @users = JSON.parse(users)
    end
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
    params[:user]['gender'] = params[:user]['gender'] == 'Mkazi' ? 'Female' : 'Male'
    paramz = {user: session[:user], new_user: params[:user], location: params[:person]}
    server_address = YAML.load_file("#{Rails.root}/config/globals.yml")[Rails.env]["user_mgmt_url"] rescue (raise "set your user Mgmt URL in globals.yml")
    uri = "http://#{server_address}/remote_create_user.json/"
    #user = RestClient.post(uri,paramz)

    user = RestClient.post(uri,paramz) { |response, request, result, &block|
      case response.code
      when 200
        response
      when 409
        raise 'User with that username already exist.'
      end
    }

    if user.blank?
      flash[:error] = 'Pepani! Wogwiritsa ntchito ameneyo alipo kale.'
      redirect_to '/user/new' and return
    else
      redirect_to '/user/list' and return
    end
  end

  def change_password
    if request.post?
      paramz = {user: session[:user], new_password: params[:user]['password'], username: params[:username]}
      server_address = YAML.load_file("#{Rails.root}/config/globals.yml")[Rails.env]["user_mgmt_url"] rescue (raise "set your user Mgmt URL in globals.yml")
      uri = "http://#{server_address}/remote_change_password.json/"
      user = RestClient.post(uri,paramz)
      redirect_to '/admin' and return
    end
  end

  def update
    params[:user]['gender'] = params[:user]['gender'] == 'Mkazi' ? 'Female' : 'Male'
    paramz = {user: session[:user], new_user: params[:user], location: params[:person], username: params[:username]}
    server_address = YAML.load_file("#{Rails.root}/config/globals.yml")[Rails.env]["user_mgmt_url"] rescue (raise "set your user Mgmt URL in globals.yml")
    uri = "http://#{server_address}/remote_update_user.json/"
    user = RestClient.post(uri,paramz)
    if user.blank?
      redirect_to "/user/edit/#{params[:username]}" and return
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
