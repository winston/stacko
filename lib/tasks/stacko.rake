# Require in Rails Env

require 'stacko'

namespace "stacko" do
  namespace "ec2" do
    desc "Create an EC2 instance"
    task :create, [:environment] do |t, args|
      file_path = File.join("#{Rails.root}", "config", "stack.yml")
      if File.exists?(file_path)
        Stacko::EC2.new(environment)
      else
        "Where's the file?"
      end
    end
  end
end
