#require 'elasticsearch/model' #(if model doesn't work then uncomment this)

class Person < CouchRest::Model::Base
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  index_name 'mtema_person_production_from_evr_couch'
  document_type 'Person'
  settings index: { number_of_shards: 5 } do
    mapping dynamic: false do
      indexes :gender, analyzer: 'english'
      # indexes :body, analyzer: 'english'
    end
  end
end

def self.search(query)
  __elasticsearch__.search(
      {
          query: {
              match: {_id: 'XEANjGMBnAPd9_e632Gt'}
          }
          # more blocks will go IN HERE. Keep reading!
      }
  )
end

def self.show
  client = Elasticsearch::Client.new host:'127.0.0.1:9200', log: true
  response = client.search index: 'mtema_person_production_from_evr_couch', body: {query: { match: {_id: 'XEANjGMBnAPd9_e632Gt'} } }
  @example = response['hits']['hits'][0]['_source']
  respond_to do |format|
    format.html # show.html.erb
    format.js # show.js.erb
    format.json { render json: @example }
  end
  @records = Example.search(@example['name']).per(12).results
end