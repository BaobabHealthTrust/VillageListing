require 'elasticsearch'

class ElasticReportsController < ApplicationController
  def index
    client = Elasticsearch::Client.new log: true
    client.cluster.health
    client.indices.refresh index: 'mtema_person_production_from_evr_couch'
    client.search index: 'mtema_person_production_from_evr_couch', body: { query: { match_all: {} } }
  end
end
