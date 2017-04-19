require 'couchrest_model'
class Relationship < CouchRest::Model::Base
use_database "Relationship"
  
  before_save :set_name_codes

  def national_id
    self['_id']
  end

  def national_id=(value)
    self['_id']=value
  end

  property :person_attributes  do
    property :country_of_residence, String
    property :citizenship, String
    property :occupation, String
    property :home_phone_number, String
    property :cell_phone_number, String
    property :office_phone_number, String
    property :race, String
  end

  property :gender, String
  property :relationship_type, String
  property :patient_id, String
  
  property :names do
    property :given_name, String
    property :family_name, String
    property :middle_name, String
    property :maiden_name, String
    property :given_name_code, String
    property :family_name_code, String
  end

  property :birthdate, String
  property :birthdate_estimated,  TrueClass, :default => false

  property :addresses do
    property :current_residence, String
    property :current_village, String
    property :current_ta, String
    property :current_district, String
    property :home_village, String
    property :home_ta, String
    property :home_district, String
  end

  timestamps!


  design do
    view :by__id,
         :map => "function(doc) {
                  if ((doc['type'] == 'Relationship')) {
                    emit(doc['_id'], 1);
                  }
                }"
  
    view :by_updated_at
     
    view :by_created_at
    
    view :by_updated_at
    
    view :by_created_at
 
    view :by_gender,
         :map => "function(doc) {
                  if ((doc['type'] == 'Relationship')) {
                    emit(doc['gender'], 1);
                  }
                }"
  end

  design do
    view :search,
         :map => "function(doc){
            if (doc['type'] == 'Relationship'){
              emit([doc.names.given_name_code ,doc.names.family_name_code, doc.gender], null);
            }
          }"

    view :advanced_search,
         :map => "function(doc){
            if (doc['type'] == 'Relationship'){
              emit([doc.names.given_name_code,doc.names.family_name_code, doc.gender, (new Date(doc.birthdate)).getFullYear(),doc.addresses.home_ta ,doc.addresses.home_district], null);
            }
          }"

    view :search_with_dob,
         :map => "function(doc){
            if (doc['type'] == 'Relationship'){
              emit([doc.names.given_name_code ,doc.names.family_name_code, doc.gender, (new Date(doc.birthdate)).getFullYear()], null);
            }
          }"
    view :search_with_home_district,
         :map => "function(doc){
            if (doc['type'] == 'Relationship' ){
              emit([doc.names.given_name_code ,doc.names.family_name_code, doc.gender, doc.addresses.home_district], null);
            }
          }"
    view :search_with_home_ta,
         :map => "function(doc){
            if (doc['type'] == 'Relationship'){
              emit([doc.names.given_name_code ,doc.names.family_name_code, doc.gender, doc.addresses.home_ta], null);
            }
          }"
    view :search_with_home_ta_district,
         :map => "function(doc){
            if (doc['type'] == 'Relationship'){
              emit([doc.names.given_name_code ,doc.names.family_name_code, doc.gender, doc.addresses.home_ta, doc.addresses.home_district], null);
            }
          }"
    view :search_with_dob_home_ta,
         :map => "function(doc){
            if (doc['type'] == 'Relationship'){
              emit([doc.names.given_name_code ,doc.names.family_name_code, doc.gender,(new Date(doc.birthdate)).getFullYear() ,doc.addresses.home_ta], null);
            }
          }"
    view :search_with_dob_home_district,
         :map => "function(doc){
            if (doc['type'] == 'Relationship'){
              emit([doc.names.given_name_code ,doc.names.family_name_code, doc.gender, (new Date(doc.birthdate)).getFullYear(),doc.addresses.home_district], null);
            }
          }"
          
  end

  design do
    view :home_district_ta_village,
         :map => "function(doc){
            if (doc['type'] == 'Relationship'){
              emit([doc.addresses.home_district ,doc.addresses.home_ta, doc.addresses.home_village], 1);
            }
          }"

    view :home_district_ta,
         :map => "function(doc){
            if (doc['type'] == 'Relationship'){
              emit([doc.addresses.home_district ,doc.addresses.home_ta], 1);
            }
          }"

    view :home_district,
         :map => "function(doc){
            if (doc['type'] == 'Relationship'){
              emit([doc.addresses.home_district], 1);
            }
          }"

    view :current_district_ta_village,
         :map => "function(doc){
            if (doc['type'] == 'Relationship'){
              emit([doc.addresses.current_district ,doc.addresses.current_ta, doc.addresses.current_village], 1);
            }
          }"

    view :current_district_ta,
         :map => "function(doc){
            if (doc['type'] == 'Relationship'){
              emit([doc.addresses.current_district ,doc.addresses.current_ta], 1);
            }
          }"

    view :current_district,
         :map => "function(doc){
            if (doc['type'] == 'Relationship'){
              emit([doc.addresses.current_district], 1);
            }
          }"
    
    view :current_empty_district,
         :map => "function(doc){
            if (doc['type'] == 'Relationship' && doc.addresses.current_district == null && doc.addresses.current_ta != null && doc.addresses.current_village != null ){
              emit([doc.addresses.current_ta, doc.addresses.current_village], 1);
            }
          }"

    view :given_name_code,
         :map => "function(doc){
            if (doc['type'] == 'Relationship'){
              emit([doc.names.given_name_code], 1);
            }
          }"

    view :family_name_code,
         :map => "function(doc){
            if (doc['type'] == 'Relationship'){
              emit([doc.names.family_name_code], 1);
            }
          }"

  end
  

  def set_name_codes
    self.names.given_name_code = self.names.given_name.soundex unless self.names.given_name.blank?
    self.names.family_name_code = self.names.family_name.soundex unless self.names.family_name.blank?
  end

 def self.search_for_person_by_params(first_name, last_name, gender, page=1)
      result = []
      fname_code = first_name.soundex
      lname_code = last_name.soundex
      
      (self.search.keys([[fname_code, lname_code, gender]]).page(page).per(10).rows).each do |row|
        person = self.find_by__id(row["id"])
        if !person.nil?
          result << person.to_json
        end
      end
 
      return result
end
    
def self.create_person(json)
  result = Person.create(json)
  return result
end
    
end
