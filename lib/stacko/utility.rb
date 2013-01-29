module Stacko
  module Utility

    def validate_config_keys(config, required_keys)
      raise 'Empty config provided' if config.nil?
      
      missing_required_keys = required_keys.select { |key| config[key].nil? || config[key].empty? }
      raise "Missing required config attributes: #{missing_required_keys}" unless missing_required_keys.empty?
      
      config
    end

  end
end
