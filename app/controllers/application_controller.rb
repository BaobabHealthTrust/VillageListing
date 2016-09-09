class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :check_if_logged_in, :except => ['login','portal', 'ping', 'dashboard']
  after_filter :user_activity, :except => ['dashboard']

  protected

  def check_if_logged_in
    if session[:user].blank?
      respond_to do |format|
        format.html { redirect_to '/portal' }
      end
    end
  end

  def print_and_redirect(print_url, redirect_url, message = "Printing, please wait...", show_next_button = false, patient_id = nil)
    @print_url = print_url
    @redirect_url = redirect_url
    @message = message
    @show_next_button = show_next_button
    @patient_id = patient_id
    render :template => 'print/print', :layout => nil
  end

  def user_activity
    if !session[:user].blank? && session[:user]['username']

      if !File.exist?("#{Rails.root}/log/lastseen")
        Dir.mkdir "#{Rails.root}/log/lastseen"
      end

      district = session[:user]['district'].downcase.gsub(/\s+/, '_').downcase
      ta = session[:user]['ta'].downcase.gsub(/\s+/, '_').downcase
      village = session[:user]['village'].downcase.gsub(/\s+/, '_').downcase
      site = "#{district}__#{ta}__#{village}"
      FileUtils.touch "#{Rails.root}/log/lastseen/#{site}"
    end
  end

end
