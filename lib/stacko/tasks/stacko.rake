require 'rubygems'
require 'erb'
require 'fileutils'

namespace "stacko" do
  desc "Initializes with config.yml"
  task :init, [:environment] do |t, args|
    puts "==> Initializing.."

    Stacko.init args.environment

    puts "==> Done!"
  end

  desc "Sets up cookbook related files"
  task :cookbooks_setup, [:environment] do |t, args|
    puts "==> Setting up cookbooks.."

    Stacko.cookbooks_setup args.environment

    puts "==> Done!"
  end

  desc "Downloads all Chef recipes listed in Cheffile to cookbooks"
  task :cookbooks_install do
    puts "==> Downloading cookbooks.."

    Stacko.cookbooks_install

    puts "==> Done!"
  end

  desc "Updates cookbooks"
  task :cookbooks_update do
    puts "==> Updating cookbooks.."

    Stacko.cookbooks_update

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
