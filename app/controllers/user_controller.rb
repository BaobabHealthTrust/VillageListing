class UserController < ApplicationController
  def login
    if request.post?
      server_address = YAML.load_file("#{Rails.root}/config/globals.yml")[Rails.env]["user_mgmt_url"] rescue (raise "set your user Mgmt URL in globals.yml")
      uri = "http://#{server_address}/remote_login.json/"
      user = RestClient.post(uri,params)
      unless user.blank?
        session[:user] = JSON.parse(user)
        redirect_to '/' and return
      end
    end
  end

  def logout
    reset_session
    redirect_to '/login' and return
  end

  def index
    render :layout => false
  end

  def username
    param = {user: session[:user], search_string: params[:search_string]}
    search("username", param)
  end

  def first_name
    params = {user: session[:user],search_string: params[:search_string]}
    search("first_name", params)
  end

  def last_name
    params = {user: session[:user],search_string: params[:search_string]}
    search("last_name", params)
  end

  private

  def search(field_name, params)
    
    server_address = '127.0.0.1:3001'

    case field_name
      when 'username'
        uri = "http://#{server_address}/get_usernames.json/"
        data = RestClient.post(uri,params)
        unless data.blank?
          session[:user] = JSON.parse(user)
          render :text => "<li>" + @names.map{|n| n } .join("</li><li>") + "</li>" and return
        end
      when 'first_name'
        uri = "http://#{server_address}/get_first_names.json/"
        data = RestClient.post(uri,params)
        unless data.blank?
          session[:user] = JSON.parse(user)
          render :text => "<li>" + @names.map{|n| n } .join("</li><li>") + "</li>" and return
        end
      when 'last_name'
        uri = "http://#{server_address}/get_last_names.json/"
        data = RestClient.post(uri,params)
        unless data.blank?
          session[:user] = JSON.parse(user)
          render :text => "<li>" + @names.map{|n| n } .join("</li><li>") + "</li>" and return
        end
    end
    
    render :text => [].to_json
  end

end
