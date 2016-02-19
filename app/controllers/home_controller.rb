class HomeController < ApplicationController
  def index
    session.delete(:dde_object) unless session[:dde_object].blank?
    render :layout => false
  end
end
