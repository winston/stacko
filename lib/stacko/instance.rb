module Stacko

  class Instance

    def initialize(config)
      @config = config
    end

    def ip_address
      raise 'Undefined'
    end

    def user_name
      raise 'Undefined'
    end

    def private_key_file
      raise 'Undefined'
    end

    def validate_config_keys(config, keys)
      if config.nil? || keys.all? { |k| config[k].nil? }
        puts "==> Fail.. Please ensure that your config file is properly formatted."
        pp config
        exit 0
      else
        config
      end
    end

  end

  class StandaloneInstance < Instance

    attr_reader :ip_address, :user_name

    def initialize(config)
      super
      validate_config_keys(config.env, %w(ip_address user_name))
      @ip_address = @config.env['ip_address']
      @user_name = @config.env['user_name']
    end

  end

  class EC2Instance < Instance
    include Stacko::Settings

    #user_name is mixed in from Settings
    #private_key_file is mixed in from Settings
    attr_reader :ip_address

    def initialize(config, ec2_host_config = nil)
      super(config)
      ec2_host_config = ec2_host_config || EC2HostsConfiguration.new('.stacko')
      @ip_address = ec2_host_config['ip_address']
    end

  end

end
