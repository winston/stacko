#!/usr/bin/env rake
require "bundler/gem_tasks"

# RSpec Tasks
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = ['--options', '.rspec']
end

task :default => :spec

## FIXME
# Import Gem's rake tasks
import  "lib/tasks/stacko.rake"
