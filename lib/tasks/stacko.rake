# Require in Rails Env

require 'stacko'

namespace "stacko" do
  namespace "ec2" do
    desc "Creates an EC2 instance"
    task :create, [:environment] do |t, args|
      file_path = File.join("#{Rails.root}", "config", "stacko.yml")
      if File.exists?(file_path)
        yaml = YAML::load(ERB.new(File.read(file_path)).result)
        env  = args.environment
        Stacko::EC2.create(yaml, env)
      else
        puts "==> Stacko requires config/stacko.yml. Please create it."
      end
    end
  end
end
