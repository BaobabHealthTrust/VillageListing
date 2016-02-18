class PeopleController < ApplicationController
  def search
  end

  def show

    redirect_to ("/") and return if session[:dde_object].blank?
    dde_object = session[:dde_object]

    @national_id = dde_object["national_id"]
    @given_name = dde_object["names"]["given_name"]
    @family_name = dde_objec["names"]["family_name"]
    person_name = @given_name.to_s + ' ' + @family_name.to_s
    @birthdate = dde_object["birthdate"]
    formatted_birthdate = @birthdate.to_date.strftime("%d/%b/%Y") rescue @birthdate
    @home_village = dde_object["addresses"]["home_village"]
    @home_ta = dde_object["addresses"]["home_ta"]
    @home_district = dde_object["addresses"]["home_district"]

    @patient_bean = {:national_id => @national_id, :name => person_name, 
      :birthdate => formatted_birthdate, :home_ta => @home_ta,
      :home_village => @home_village, :home_district => @home_district}

    @patient_bean = OpenStruct.new @patient_bean #Making the keys accessible by a dot operator
  end

  def national_id_label

  end
  
end
