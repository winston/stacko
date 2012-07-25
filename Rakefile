#!/usr/bin/env rake
require 'bundler/gem_tasks'

# RSpec Tasks
require 'rspec/core/rake_task'

# Stacko Tasks
load 'lib/tasks/stacko.rake'

RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = ['--options', '.rspec']
end

task :default => :spec
