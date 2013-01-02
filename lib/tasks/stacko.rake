require 'rubygems'
require 'erb'

namespace "stacko" do
  desc "Initializes with Cheffile and Chef cookbooks"
  task :init do
    puts "==> Initializing.."

    system("knife kitchen .")
    system("librarian-chef init")

    # Pulls in default recipes?

    puts "==> Done!"
  end

  desc "Downloads all Chef recipes listed in Cheffile to cookbooks"
  task :cookbooks_install do
    puts "==> Downloading cookbooks.."

    system("librarian-chef install")

    puts "==> Done!"
  end

  desc "Launches an EC2 instance"
  task :server_create, [:environment] do |t, args|
    if args.to_hash.length < 1
      puts "==> Please run 'rake stacko:server_create[environment]'. Thank you."
      exit 0
    end

    puts "==> Creating.."
    Stacko.create_ec2_instance args.environment
    puts "==> Done!"
  end

  desc "Installs Chef-solo into remote server"
  task :server_init, [:environment] do |t, args|
    if args.to_hash.length < 1
      puts "==> Please run 'rake stacko:server_init[environment]'. Thank you."
      exit 0
    end

    puts "==> Creating.."
    Stacko.install_chef args.environment
    puts "==> Done!"
  end

  desc "Uploads all cookbooks to EC2 instance and performs chef-solo"
  task :server_install, [:environment] do |t, args|
    if args.to_hash.length < 1
      puts "==> Please run 'rake stacko:server_install[environment]'. Thank you."
      exit 0
    end

    puts "==> Installing.."
    Stacko.run_chef args.environment
    puts "==> Done!"

  end

end
