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
    desc "Sets up Chefile for specific role, and downloads all recipes to cookbooks"
    task :install, [:environment, :cookbook] do |t, args|
      if args.to_hash.length < 2
        puts "==> Please run 'rake stacko:cookbook:install[environment,cookbook]'. Thank you."
        exit 0
      end

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

  namespace "server" do
    desc "Launches an EC2 instance"
    task :create_ec2, [:environment] do |t, args|
      if args.to_hash.length < 1
        puts "==> Please run 'rake stacko:server:create_ec2[environment]'. Thank you."
        exit 0
      end

      puts "==> Creating.."
      Stacko.create_ec2_instance args.environment
      puts "==> Done!"
    end

    desc "Installs chef-solo into remote server, Uploads all cookbooks to EC2 instance and chef-solo"
    task :install, [:environment] do |t, args|
      if args.to_hash.length < 1
        puts "==> Please run 'rake stacko:server:install[environment]'. Thank you."
        exit 0
      end

      puts "==> Installing chef-solo.."
      Stacko.install_chef args.environment

      puts "==> Running chef-solo.."
      Stacko.run_chef args.environment

      puts "==> Done!"
    end
  end
end
