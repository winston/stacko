require 'spec_helper'

describe Stacko::Instance do
  include Stacko::Settings

  # Mocks
  let(:stack)               { Stacko::Instance.new(aws_config) }
  let(:aws_ec2)             { mock(:aws_ec2) }
  let(:instance)            { mock(:ec2_instance, id: "id-1234", ip_address: "127.0.0.1", status: :running, tags: {"environment" => environment}) }

  # Expectations
  let(:environment)         { "production" }
  let(:create_config)       { YAML::load(File.read("#{File.dirname(__FILE__)}/../fixtures/stacko.yml")) }
  let(:aws_config)          { create_config["aws"] }
  let(:ec2_config)          { create_config["env"][environment] }
  let(:load_config)         { YAML::load(File.read("#{File.dirname(__FILE__)}/../fixtures/dotstacko.yml")) }
  let(:instance_config)     { load_config[environment]}

  describe "#initialize" do
    it "initializes AWS config with environment variables" do
      AWS::EC2.should_receive(:new).with(aws_config)

      Stacko::Instance.new(aws_config)
    end
  end

  describe "#launch" do
    before { AWS::EC2.should_receive(:new) { aws_ec2 } }

    it "creates a new instance on AWS" do
      aws_ec2.should_receive(:instances) { aws_ec2 }
      aws_ec2.should_receive(:create)
        .with(ec2_config.merge({"key_name" => key_name, "security_groups" => [security_group_name]}))
        .and_return(instance)

      instance.should_receive(:tag).with("environment", {value: environment})

      stack.stub!(:sleep)
      stack.launch(environment, ec2_config)
    end
  end

  describe "#load" do
    before { AWS::EC2.should_receive(:new) { aws_ec2 } }

    it "loads an instance" do
      aws_ec2.should_receive(:instances) { aws_ec2 }
      aws_ec2.should_receive(:[]).with(instance_config["instance_id"])

      stack.load(instance_config)
    end
  end

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

  describe "#to_hash" do
    before do
      AWS::EC2.should_receive(:new) { aws_ec2 }
      stack.instance_variable_set(:@instance, instance)
    end

    it "returns a hash of details" do
      stack.to_hash.should == { environment => { "instance_id" => instance.id, "ip_address" => instance.ip_address } }
    end
  end

end
