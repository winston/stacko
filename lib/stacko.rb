require "stacko/version"


lib_path = File.dirname(__FILE__)
require "#{lib_path}/stacko/app/railtie.rb" if defined?(Rails)
require "#{lib_path}/stacko/ec2"
