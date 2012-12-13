require 'simplecov'
SimpleCov.start

require 'rubygems'
require 'bundler/setup'
Bundler.require :default

require 'qbxml'
RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.filter_run :focus => true
  config.run_all_when_everything_filtered = true
end

SUPPORT_DIR  = "#{File.dirname(__FILE__)}/support" unless defined? SUPPORT_DIR
REQUEST_DIR  = "#{SUPPORT_DIR}/requests" unless defined? REQUEST_DIR
RESPONSE_DIR = "#{SUPPORT_DIR}/responses" unless defined? RESPONSE_DIR

def requests
  Dir["#{REQUEST_DIR}/*.xml"].map { |f| File.read(f) }
end

def responses
  Dir["#{RESPONSE_DIR}/*.xml"].map { |f| File.read(f) }
end
