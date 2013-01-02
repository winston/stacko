module Stacko

  module ConfigurationFileUtilities

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

  class EC2HostsConfiguration
    include ConfigurationFileUtilities

    def initialize(config_file, environment)
      config = read_yaml(config_file)[environment]
      @config = validate_yaml(config, %w(instance_id ip_address))
    end

    def [](key)
      @config[key]
    end

  end

  class Configuration
    include ConfigurationFileUtilities

    attr_accessor :environment

    # Initialize
    #
    # Parameters
    #   * config_file: Path to the config file
    #   * environment: Pull configuration for this environment

    def initialize(config_file, environment)
      @config = read_yaml(config_file)
      @environment = environment
    end

    def [](key)
      @config[key]
    end

    def type
      @config['host']['type']
    end

    def type?(host_type)
      host_type == @config['host']['type']
    end

    # Reading from config/stacko.yml:
    #
    # global:
    #   type: aws
    #   access_key_id: "123"
    #   secret_access_key: "abc"
    #   ec2_endpoint: "ec2.ap-southeast-1.amazonaws.com"
    
    def global
      @config['global']
      #validate_yaml(@config["host"], %w(access_key_id secret_access_key))
    end

    # Reading from config/stacko.aws.yml:
    #
    # env:
    #   staging:
    #     image_id: "ami-1234"
    #     instance_type: "m1.small"
    #   production:
    #     image_id: "ami-1234"
    #     instance_type: "m1.large"
    #
    def env
      @config["env"][environment]
      #validate_yaml(@config["env"][environment], %w(image_id instance_type))
    end

  end

end
