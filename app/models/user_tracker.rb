require 'couchrest_model'

class UserTracker < CouchRest::Model::Base
	
	use_database :user_tracker
	
	property :person_tracker, String
	property :username, String
	
	timestamps!
	
	design do
		view :by__id,
		     :map => "function(doc) {
                    if ((doc['type'] == 'UserTracker')) {
                        emit(doc['_id'], 1);
                    }
             }"
		
		view :by_person_tracker,
		     :map => "function(doc) {
					if(doc['type'] == 'UserTracker') {
						emit(doc.person_tracker, 1);
					}
			 }"

		view :by_username,
				 :map => "function(doc) {
					if(doc['type'] == 'UserTracker') {
						emit(doc.username, 1);
					}
			 }"
		
		view :by_updated_at
		
		view :by_created_at,
			 :map => "function(doc) {
					if(doc['type'] == 'UserTracker'){
						emit(doc.created_at, 1)
					}
			 }"
	end

end
