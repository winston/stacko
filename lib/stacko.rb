lib_path = File.dirname(__FILE__)

require 'aws-sdk'
require 'pp'
require "#{lib_path}/stacko/utility"
require "#{lib_path}/stacko/ec2_settings"
require "#{lib_path}/stacko/server"
require "#{lib_path}/stacko/instance"
require "#{lib_path}/stacko/ec2_instance_spawner"
require "#{lib_path}/stacko/configuration"
require "#{lib_path}/stacko/knife_operation"

module Stacko
  class << self

    def create_ec2_instance(environment)
      # FIXME: Verify if there alread is an instance for the environment we are trying to launch

      config = Stacko::Configuration.new(File.join("config", "stacko.yml"), environment)
      ec2_config = Stacko::EC2HostsConfiguration.new(File.join(".stacko"), environment)

      server = Stacko::Server.new config.global
      server.create_key_pair
      server.create_security_group

      instance = Stacko::EC2InstanceSpawner.new config, ec2_config
      instance.launch
      instance.save_config

    end

    def install_chef(environment)
      config = Stacko::Configuration.new(File.join("config", "stacko.yml"), environment)
      instance = instance_factory config, environment
      KnifeOperation.new(instance).prepare
    end

    def run_chef(environment)
      config = Stacko::Configuration.new(File.join("config", "stacko.yml"), environment)
      instance = instance_factory config, environment
      KnifeOperation.new(instance).cook
    end

    private

    def instance_factory config, environment
      if config.type?('ec2')
        ec2_config = Stacko::EC2HostsConfiguration.new(File.join(".stacko"), environment)
        Stacko::EC2Instance.new config, ec2_config
      else
        Stacko::StandaloneInstance.new config
      end
    end
  end
end
