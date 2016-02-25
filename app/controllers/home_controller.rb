class HomeController < ApplicationController
  def index
    session.delete(:dde_object) unless session[:dde_object].blank?

    @settings = YAML.load_file("#{Rails.root}/config/dde_connection.yml")[Rails.env] rescue {}

    render :layout => false
  end
end
