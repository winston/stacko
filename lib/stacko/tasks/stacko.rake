require 'rubygems'
require 'erb'
require 'fileutils'

desc "Initializes with config.yml"
task :stacko do |t, args|
  puts "==> Initializing.."
  Stacko.init
  puts "==> Done!"
end

namespace "stacko" do
  namespace "cookbook" do
    desc "Sets up Chefile for specific role, and downloads all recipes to cookbooks."
    task :install, [:environment, :cookbook] do |t, args|
      puts "==> Setting up cookbooks.."
      Stacko.init_cookbook args.environment, args.cookbook

      puts "==> Downloading cookbooks.."
      Stacko.install_cookbook

      puts "==> Done!"
    end

    desc "Updates cookbook"
    task :update do
      puts "==> Updating cookbooks.."
      Stacko.update_cookbook
      puts "==> Done!"
    end
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
