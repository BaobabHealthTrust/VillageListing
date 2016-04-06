# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Initialize the Rails application.
Rails.application.initialize!

APP_VERSION = `git describe`.gsub("\n", "")

require 'json'
require 'csv'
require 'rest_client'
