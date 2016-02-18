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
    patient_bean = formatted_dde_object
    print_string = patient_national_id_label(patient_bean)
    send_data(print_string,:type=>"application/label; charset=utf-8", :stream=> false,
      :filename=>"test.lbl", :disposition => "inline")
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

  def patient_national_id_label(patient_bean)
    print_string = %Q(
N
q812
Q305,026
ZT
B35,170,0,1,5,15,100,N,"#{patient_bean.national_id}"
A35,30,0,2,2,2,N,"#{patient_bean.name}"
A35,76,0,2,2,2,N,"#{patient_bean.national_id} #{patient_bean.birthdate}(#{patient_bean.gender})"
    A35,122,0,2,2,2,N,"#{patient_bean.home_ta}, #{patient_bean.home_village}"
    P1)
  return print_string
    
  end

  def formatted_dde_object
    dde_object = session[:dde_object]

    national_id = dde_object["national_id"]
    given_name = dde_object["names"]["given_name"]
    family_name = dde_objec["names"]["family_name"]
    person_name = given_name.to_s + ' ' + family_name.to_s
    birthdate = dde_object["birthdate"]
    formatted_birthdate = birthdate.to_date.strftime("%d/%b/%Y") rescue birthdate
    home_village = dde_object["addresses"]["home_village"]
    home_ta = dde_object["addresses"]["home_ta"]
    home_district = dde_object["addresses"]["home_district"]

    patient_bean = {:national_id => national_id, :name => person_name,
        :birthdate => formatted_birthdate, :home_ta => home_ta,
        :home_village => home_village, :home_district => home_district}

    patient_bean = OpenStruct.new patient_bean #Making the keys accessible by a dot operator
    return patient_bean
  end


end
