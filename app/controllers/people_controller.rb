class PeopleController < ApplicationController
  def search
  end

  def show
=begin
    redirect_to ("/") if session[:dde_object].blank?
    dde_object = session[:dde_object]
    @national_id = dde_object[:national_id]
    @given_name = dde_object[:national_id][:names][:given_name]
    @family_name = dde_object[:national_id][:names][:family_name]
    @birthdate = dde_object[:national_id][:birthdate]
=end
  end

  def national_id_label

  end

  def get_names
    if params[:search_str].blank?
      params[:search_str] = 'A'
    end
    
    paramz = {user: session[:user], search_str: params[:search_str], name: params[:name]}
    server_address = '127.0.0.1:3001'
    uri = "http://#{server_address}/demographics/#{params[:name]}.json/"
    names = RestClient.post(uri,paramz)

    unless names.blank?
      @names = JSON.parse(names)
      render :text => "<li>" + @names.map{|n| n } .join("</li><li>") + "</li>" and return
    else
      @names = [] 
      render :text => "<li>" + @names.map{|n| n } .join("</li><li>") + "</li>" and return
    end

  end  

end
