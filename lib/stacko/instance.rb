module Stacko

  class Instance
    include Stacko::Utility
    def initialize(config)
      @config = config
    end

    def ip_address
      raise NotImplementedError
    end

    def username
      raise NotImplementedError
    end

    def private_key_file
      raise NotImplementedError
    end

    def private_key_file?
      File.exists?(private_key_file.to_s)
    end

    def password
      @config.env['password'].to_s
    end

    def password?
      !password.empty?
    end

    def environment
      @config.environment
    end
  end

  class StandaloneInstance < Instance

    attr_reader :ip_address, :username

    def initialize(config)
      super
      validate_config_keys(config.env, %w(ip_address username))
      @ip_address = @config.env['ip_address']
      @username = @config.env['username']
    end

    def private_key_file
      @config.env['private_key_file'].to_s
    end

  end

  class EC2Instance < Instance
    include Stacko::EC2Settings

    #username is mixed in from Settings
    #private_key_file is mixed in from Settings
    attr_reader :ip_address

    def initialize(config, ec2_host_config = nil)
      super(config)
      ec2_host_config = ec2_host_config || EC2HostsConfiguration.new('.stacko')
      @ip_address = ec2_host_config['ip_address']
    end

  end

end
