require 'spec_helper.rb'

describe Stacko::RunningInstance do
  describe "#prepare" do
    before do
      AWS::EC2.should_receive(:new) { aws_ec2 }
      stack.instance_variable_set(:@instance, instance)
    end

    it "executes knife prepare" do
      stack.should_receive("system").with("knife prepare #{user_name}@#{instance.ip_address} -i #{private_key_file}")

      stack.prepare
    end
  end

  describe "#install" do
    before do
      AWS::EC2.should_receive(:new) { aws_ec2 }
      stack.instance_variable_set(:@instance, instance)
    end

    it "executes knife cook" do
      stack.should_receive("system").with("knife cook #{user_name}@#{instance.ip_address} -i #{private_key_file}")

      stack.install
    end
  end
end
