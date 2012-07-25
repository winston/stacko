require 'rubygems'
require 'bundler/setup'

# Configure Rails Environment
ENV["RAILS_ENV"] = "test"
require File.expand_path("../dummy/config/environment.rb",  __FILE__)

RSpec.configure do |config|
  # some (optional) config here
end
