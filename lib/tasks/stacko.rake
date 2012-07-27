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

  desc "Launches an EC2 instance and prepares it for Chef-solo"
  task :server_create, [:environment] do |t, args|
    if args.to_hash.length < 1
      puts "==> Please run 'rake stacko:server_create[environment]'. Thank you."
      exit 0
    end

    puts "==> Creating.."
    Stacko.create args.environment
    puts "==> Done!"
  end

  desc "Uploads all cookbooks to EC2 instance and performs chef-solo"
  task :server_install, [:environment] do |t, args|
    if args.to_hash.length < 1
      puts "==> Please run 'rake stacko:server_install[environment]'. Thank you."
      exit 0
    end

    puts "==> Installing.."
    Stacko.install args.environment
    puts "==> Done!"

  end

end
