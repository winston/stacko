#!/usr/bin/env rake
require 'bundler/gem_tasks'

# RSpec Tasks
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = ['--options', '.rspec']
end

task :default => :spec

# Stacko Tasks
require File.join(File.dirname(__FILE__), 'lib', 'stacko' )
require File.join(File.dirname(__FILE__), 'lib', 'stacko', 'tasks' )
