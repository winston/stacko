module Stacko
  class KnifeOperation

    def initialize(instance)
      @instance = instance
    end

    %w(prepare cook).each do |operation|
      define_method(operation) do

        raise "You should either supply a private key file or password." if !@instance.password? and !@instance.private_key_file?

        puts "==> Preparing EC2 instance with chef-solo..."
        puts "==> Running '#{command(operation)}'"
        system(command(operation))
        puts "==> Finished preparing instance '#{@instance.ip_address}'"
      end
    end

    def command(operation)
      if @instance.private_key_file?
        command = "#{command_prefix(operation)} -i #{@instance.private_key_file}"
      elsif @instance.password?
        command = "#{command_prefix(operation)} -P #{@instance.password}"
      end
    end

    def command_prefix operation
      "knife solo #{operation} #{@instance.username}@#{@instance.ip_address}"
    end


  end
end
