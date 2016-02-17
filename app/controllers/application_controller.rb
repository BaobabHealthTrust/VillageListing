class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :check_if_logged_in, :except => ['login']

  protected

  def check_if_logged_in
    if session[:user].blank?
      respond_to do |format|
        format.html { redirect_to '/login' }
      end
    end
  end

end
