module Stacko
  class KnifeOperation

    def initialize(instance)
      @instance = instance
    end

    %w(prepare cook).each do |operation|
      define_method(operation) do

        raise "You should either supply a private key file or password." if !@instance.password? and !@instance.private_key_file?

        puts "==> Preparing with chef-solo..."
        puts "==> Running '#{command(operation)}'"
        system(command(operation))
        puts "==> Finished preparing instance '#{@instance.ip_address}'"
      end
    end

    def init
      FileUtils.mkdir_p '.chef'
      FileUtils.touch '.chef/knife.rb'
      system("knife solo init .")
    end

    def command(operation)
      if @instance.private_key_file?
        command = "#{command_prefix(operation)} -i #{@instance.private_key_file}"
      elsif @instance.password?
        command = "#{command_prefix(operation)} -P #{@instance.password}"
      end

      "#{command} nodes/#{@instance.environment}.json"
    end

    def command_prefix operation
      "knife solo #{operation} #{@instance.username}@#{@instance.ip_address}"
    end

  end
end
