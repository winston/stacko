require 'rubygems'
require 'erb'
require 'fileutils'

gem_dir = File.join(File.dirname(__FILE__), '..', '..')
templates_dir = File.join(gem_dir, 'lib', 'generators', 'templates')

def copy_template(template_name, dest_dir)
  dest_file = File.join(dest_dir, template_name)
  if File.exist?(dest_file)
    puts "WARNING: File #{dest_file} exists, please delete it if you want to revert to defaults"
  else
    FileUtils.cp "#{File.join(templates_dir, template_name + '.sample')}", dest_dir
  end
end

namespace "stacko" do
  desc "Initializes with Cheffile and Chef cookbooks"
  task :init do
    puts "==> Initializing.."

    if File.exists?('cookbooks')
      FileUtils.rm_rf 'cookbooks'
    end
    system("knife kitchen .")
    copy_template('Cheffile', '.')
    FileUtils.mkdir_p 'config'
    copy_template('stacko.yml', 'config')

    puts "==> Done!"
  end

  desc "Updates cookbooks"
  task :cookbooks_update do
    puts "==> Updating cookbooks.."

    system("librarian-chef update")

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
