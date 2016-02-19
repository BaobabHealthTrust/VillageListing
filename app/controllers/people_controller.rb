class PeopleController < ApplicationController
  def search
  end

  def show

    redirect_to ("/") and return if session[:dde_object].blank?

    @patient_bean = formatted_dde_object

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

  national_id = dde_object["_id"]
  national_id = dde_object["national_id"] if national_id.blank?

  given_name = dde_object["names"]["given_name"]
  middle_name = dde_object["names"]["middle_name"]
  family_name = dde_object["names"]["family_name"]
  person_name = given_name.to_s + ' ' + family_name.to_s
  birthdate = dde_object["birthdate"]
  formatted_birthdate = birthdate.to_date.strftime("%d/%b/%Y") rescue birthdate

  current_residence = dde_object["addresses"]["current_residence"]
  current_village = dde_object["addresses"]["current_village"]
  current_ta = dde_object["addresses"]["current_ta"]
  current_district = dde_object["addresses"]["current_district"]

  home_village = dde_object["addresses"]["home_village"]
  home_ta = dde_object["addresses"]["home_ta"]
  home_district = dde_object["addresses"]["home_district"]

  gender = dde_object["gender"]

  patient_bean = {
    :national_id => national_id,
      :first_name => given_name,
      :middle_name => middle_name,
      :last_name => family_name,
      :name => person_name,
      :birthdate => formatted_birthdate,
      :current_residence => current_residence,
      :current_village => current_village,
      :current_ta => current_ta,
      :current_district => current_district,
      :home_ta => home_ta,
      :home_village => home_village, :home_district => home_district,
      :sex => gender
  }

  patient_bean = OpenStruct.new patient_bean #Making the keys accessible by a dot operator
  return patient_bean
end

def demographics
  redirect_to ("/") and return if session[:dde_object].blank?
  settings = YAML.load_file("#{Rails.root}/config/globals.yml")[Rails.env] rescue {}

  @settings = YAML.load_file("#{Rails.root}/config/dde_connection.yml")[Rails.env] rescue {}

  @show_middle_name = (settings["show_middle_name"] == true ? true : false) rescue false

  @show_maiden_name = (settings["show_maiden_name"] == true ? true : false) rescue false

  @show_birthyear = (settings["show_birthyear"] == true ? true : false) rescue false

  @show_birthmonth = (settings["show_birthmonth"] == true ? true : false) rescue false

  @show_birthdate = (settings["show_birthdate"] == true ? true : false) rescue false

  @show_age = (settings["show_age"] == true ? true : false) rescue false

  @show_region_of_origin = (settings["show_region_of_origin"] == true ? true : false) rescue false

  @show_district_of_origin = (settings["show_district_of_origin"] == true ? true : false) rescue false

  @show_t_a_of_origin = (settings["show_t_a_of_origin"] == true ? true : false) rescue false

  @show_home_village = (settings["show_home_village"] == true ? true : false) rescue false

  @show_current_region = (settings["show_current_region"] == true ? true : false) rescue false

  @show_current_district = (settings["show_current_district"] == true ? true : false) rescue false

  @show_current_t_a = (settings["show_current_t_a"] == true ? true : false) rescue false

  @show_current_village = (settings["show_current_village"] == true ? true : false) rescue false

  @show_current_landmark = (settings["show_current_landmark"] == true ? true : false) rescue false

  @show_cell_phone_number = (settings["show_cell_phone_number"] == true ? true : false) rescue false

  @show_office_phone_number = (settings["show_office_phone_number"] == true ? true : false) rescue false

  @show_home_phone_number = (settings["show_home_phone_number"] == true ? true : false) rescue false

  @show_occupation = (settings["show_occupation"] == true ? true : false) rescue false

  @show_nationality = (settings["show_nationality"] == true ? true : false) rescue false

  @show_country_of_residence = (settings["show_country_of_residence"] == true ? true : false) rescue false

  @occupations = ['','Driver','Housewife','Messenger','Business','Farmer','Salesperson','Teacher',
      'Student','Security guard','Domestic worker', 'Police','Office worker',
      'Preschool child','Mechanic','Prisoner','Craftsman','Healthcare Worker','Soldier'].sort.concat(["Other","Unknown"])

  @patient_bean = formatted_dde_object
end

end
