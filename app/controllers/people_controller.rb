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
  
end
