lib_path = File.dirname(__FILE__)

require 'aws-sdk'
require 'pp'
require "#{lib_path}/stacko/settings"
require "#{lib_path}/stacko/server"
require "#{lib_path}/stacko/instance"

module Stacko
  class << self

    # Runs through the steps for creating a new EC2 instance
    #
    def create(environment)
      # FIXME: Verify if env already exists?

      server   = Stacko::Server.new   aws_config
      server.create_key_pair
      server.create_security_group

      instance = Stacko::Instance.new aws_config
      instance.launch environment, ec2_config(environment)
      instance.prepare

      save_to_yaml(instance.to_hash)
    end

    # Runs through the steps for running chef-solo on an EC2 instance
    #
    def install(environment)
      # FIXME: Verify if env already exists?

      instance = Stacko::Instance.new aws_config
      instance.load instance_config(environment)
      instance.install
    end

    # Reading from config/stacko.yml:
    #
    # aws:
    #   access_key_id: "123"
    #   secret_access_key: "abc"
    #   ec2_endpoint: "ec2.ap-southeast-1.amazonaws.com"
    # ....
    #
    def aws_config
      file   = File.join("config", "stacko.yml")
      config = read_yaml(file)["aws"]
      validate_yaml(config, %w(access_key_id secret_access_key))
    end

    # Reading from config/stacko.yml:
    #
    # ....
    # env:
    #   staging:
    #     image_id: "ami-1234"
    #     instance_type: "m1.small"
    #   production:
    #     image_id: "ami-1234"
    #     instance_type: "m1.large"
    #
    def ec2_config(environment)
      file   = File.join("config", "stacko.yml")
      config = read_yaml(file)["env"][environment]
      validate_yaml(config, %w(image_id instance_type))
    end

    # Reading from .stacko:
    #
    # staging:
    #   instance_id: "ami-1234"
    #   ip_address: 1.2.3.4
    # production:
    #   instance_id: "ami-1234"
    #   ip_address: 1.2.3.4
    #
    def instance_config(environment)
      file   = File.join(".stacko")
      config = read_yaml(file)[environment]
      validate_yaml(config, %w(instance_id ip_address))
    end

    def save_to_yaml(hash)
      File.open(".stacko", "a") do |file|
        file.write(hash.to_yaml)
      end
    end

    private

    def read_yaml(file_path)
      if File.exists?(file_path)
        YAML::load(ERB.new(File.read(file_path)).result)
      else
        puts "==> We cannot find the #{file_path}. Where is it?"
        exit 0
      end
    end

    def validate_yaml(config, keys)
      if config.nil? || keys.all? { |k| config[k].nil? }
        puts "==> Fail.. Please ensure that your config file is properly formatted."
        pp config
        exit 0
      else
        config
      end
    end

  end

end
