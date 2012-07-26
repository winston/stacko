namespace "stacko" do
  desc "Initializes [directory] with Chef files"
  task :init, [:directory] do |t, args|
    args.with_defaults(directory: ".")

    puts "==> Initializing.."

    `knife kitchen #{args.directory}`
    `cd #{args.directory} && librarian-chef init`

    # Pulls in default recipes?

    puts "==> Done!"
  end

  desc "Launches an EC2 instance with the proper key pair and security group"
  task :server_create   , [:environment] do |t, args|
    if args.to_hash.length < 1
      puts "==> Please run 'rake stacko:server_create[environment]'. Thank you."
      exit 0
    end

    file_path = File.join("config", "stacko.yml")
    if !File.exists?(file_path)
      puts "==> Stacko requires config/stacko.yml. Please create it."
      exit 0
    end

    puts "==> Creating.."

    yaml = YAML::load(ERB.new(File.read(file_path)).result)
    env  = args.environment
    Stacko::Server.create(yaml, env)

    puts "==> Done!"
  end

  desc "Performs chef-solo on an EC2 instance"
  task :server_install  , [:environment] do |t, args|
    if args.to_hash.length < 1
      puts "==> Please run 'rake stacko:server_install[environment]'. Thank you."
      exit 0
    end

    file_path = File.join("config", "stacko.yml")
    if !File.exists?(file_path)
      puts "==> Stacko requires config/stacko.yml. Please create it."
      exit 0
    end

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
