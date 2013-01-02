lib_path = File.dirname(__FILE__)

require 'aws-sdk'
require 'pp'
require "#{lib_path}/stacko/settings"
require "#{lib_path}/stacko/server"
require "#{lib_path}/stacko/instance"
require "#{lib_path}/stacko/ec2_instance_spawner"
require "#{lib_path}/stacko/configuration"
require "#{lib_path}/stacko/running_instance"

module Stacko
  class << self

    # Runs through the steps for creating a new EC2 instance
    #
    def create_ec2_instance(environment)
      # FIXME: Verify if there alread is an instance for the environment we are trying to launch

      config = Stacko::Configuration.new(File.join("config", "stacko.yml"), environment)

      server = Stacko::Server.new config.aws_config
      server.create_key_pair
      server.create_security_group

      instance = Stacko::EC2InstanceSpawner.new config
      instance.launch

      save_to_yaml(instance.to_hash)
    end

    def install_chef(environment)
      config = Stacko::Configuration.new(File.join("config", "stacko.yml"), environment)
      instance = instance_factory config
      RunningInstance.new(instance).prepare
    end

    def run_chef(environment)
      config = Stacko::Configuration.new(File.join("config", "stacko.yml"), environment)
      instance = Stacko::Instance.new config
      RunningInstance.new(instance).install
    end

    private

    def instance_factory config
      if config.type?('ec2')
        Stacko::EC2Instance.new config
      else
        Stacko::StandaloneInstance.new config
      end
    end

    def save_to_yaml(hash)
      File.open(".stacko", "a") do |file|
        file.write(hash.to_yaml)
      end
    end

  end
end
