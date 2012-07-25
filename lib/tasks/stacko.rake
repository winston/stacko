namespace "stacko" do
  desc "Initializes Chef stuff in current directory"
  task :init, [:directory] do |t, args|
    # If given a git url, clone that dir instad

    args.with_defaults(directory: ".")
    puts "==> Initializing.."
    `knife kitchen #{args.directory}`
    `cd #{args.directory} && librarian-chef init`
    puts "==> Done"
  end

  desc "Creates an EC2 instance"
  task :create_server, [:environment] do |t, args|
    file_path = File.join("#{Rails.root}", "config", "stacko.yml")
    if File.exists?(file_path)
      yaml = YAML::load(ERB.new(File.read(file_path)).result)
      env  = args.environment
      Stacko::Server.create(yaml, env)
    else
      puts "==> Stacko requires config/stacko.yml. Please create it."
    end
  end

  desc "Processes Cheffile and chef-solo an EC2 instance"
  task :install_server do
    puts "==> Installing.."

    puts "==> Downloading cookbooks.."
    `librarian-chef install`
    puts "==> Successfully downloaded cookbooks"

    puts "==> Deploying and Executing cookbooks.."
    `knife-solo cook #{user@machine}`
    puts "==> Successfully deployed and executed cookbooks"

    puts "==> Done"
  end
end
