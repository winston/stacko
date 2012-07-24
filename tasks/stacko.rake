# Require in Rails Env

require 'stacko'

namespace "stacko" do
  namespace "ec2" do
    desc "Create an EC2 instance"
    task :create, [:image_id, :instance_type] do |t, args|
      if args.to_hash.empty?
        puts "==> Please run this task with an AMI and Instance Type, e.g. 'rake stacko:ec2:create[ami-1234,m1.micro]'"
        exit 0
      end
      stack = Stacko::EC2.new
      stack.create_key_pair
      stack.create_security_group
      stack.create_instance(args.image_id, args.instance_type)
    end
  end
end
