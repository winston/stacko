namespace "stacko" do
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
end
