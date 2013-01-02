module Stacko

  module ConfigurationFileUtilities
    include Stacko::Utility

    def read_yaml(file_path)
      if File.exists?(file_path)
        YAML::load(ERB.new(File.read(file_path)).result)
      else
        puts "==> We cannot find the #{file_path}. Where is it?"
      end
    end

    def save_yaml(hash, file_path)
      File.open(file_path, "a") do |file|
        file.write(hash.to_yaml)
      end
    end

  end

  class EC2HostsConfiguration
    include ConfigurationFileUtilities

    def initialize(config_file, environment)
      @config_file = config_file
      @environment = environment
    end

    def [](key)
      @config ||= validate_config_keys(read_yaml(@config_file)[@environment], %w(instance_id ip_address))
      @config[key]
    end

    def save hash
      save_yaml hash, @config_file
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
      @config = validate_config_keys(read_yaml(config_file), %w(global env))
      @environment = environment
    end

    def [](key)
      @config[key]
    end

    def type
      @config['global']['type']
    end

    def type?(host_type)
      host_type == type
    end

    # Reading from config/stacko.ec2.yml:
    #
    # global:
    #   type: ec2
    #   access_key_id: "123"
    #   secret_access_key: "abc"
    #   ec2_endpoint: "ec2.ap-southeast-1.amazonaws.com"

    def global
      @config['global']
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
    end

  end

end
