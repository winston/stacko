module Stacko
  class RunningInstance
    def initialize(instance)
      @instance = instance
    end

    def prepare
      puts "==> Preparing EC2 instance with chef-solo..."
      puts "==> Running 'knife prepare #{@instance.user_name}@#{@instance.ip_address} -i #{@instance.private_key_file}'"
      system("knife prepare #{@instance.user_name}@#{@instance.ip_address} -i #{@instance.private_key_file}")
      puts "==> Finished preparing EC2 instance '#{@instance.ip_address}'"
    end

    def install
      puts "==> Installing cookbooks on EC2 instance..."
      puts "==> Running 'knife cook #{@instance.user_name}@#{@instance.ip_address} -i #{@instance.private_key_file}'"
      system("knife cook #{@instance.user_name}@#{@instance.ip_address} -i #{@instance.private_key_file}")
      puts "==> Finished installing cookbooks"
    end
  end
end
