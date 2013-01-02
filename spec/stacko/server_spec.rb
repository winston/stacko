require 'spec_helper'

describe Stacko::Server do
  include Stacko::Settings

  # Mocks
  let(:stack)               { Stacko::Server.new(aws_config) }
  let(:aws_ec2)             { mock(:aws_ec2) }
  let(:key_pair)            { mock(:key_pair, private_key: "oh so private") }
  let(:security_group)      { mock(:security_group) }
  let(:file)                { StringIO.new }

  # Expectations
  let(:yaml)                { YAML::load(File.read("#{File.dirname(__FILE__)}/../fixtures/stacko.aws.yml")) }
  let(:aws_config)          { yaml["aws"] }

  describe "#initialize" do
    it "initializes AWS config with environment variables" do
      AWS::EC2.should_receive(:new).with(aws_config)

      Stacko::Server.new(aws_config)
    end
  end

  describe "#create_key_pair" do
    before { AWS::EC2.should_receive(:new) { aws_ec2 } }

    it "creates a key pair and saves the private key to ~/.ec2/<project>.pem" do
      aws_ec2.should_receive(:key_pairs) { aws_ec2 }
      aws_ec2.should_receive(:create).with(key_name) { key_pair }

      File.should_receive(:open).with(private_key_file, "w", 0600).and_yield(file)

      stack.create_key_pair
      file.string.should == key_pair.private_key
    end

    it "rescues and continues when exception for duplicate key pair is raised" do
      aws_ec2.should_receive(:key_pairs) { aws_ec2 }
      aws_ec2.should_receive(:create).with(key_name).and_raise(AWS::EC2::Errors::InvalidKeyPair::Duplicate)

      stack.create_key_pair
    end
  end

  describe "#create_security_group" do
    before { AWS::EC2.should_receive(:new) { aws_ec2 } }

    it "creates a new security group <project_name>-web, and adds ingress traffic for HTTP, SSH and ICMP" do
      aws_ec2.should_receive(:security_groups) { aws_ec2 }
      aws_ec2.should_receive(:create).with(security_group_name) { security_group }

      security_group.should_receive(:allow_ping)
      security_group.should_receive(:authorize_ingress).with(:tcp, 80)
      security_group.should_receive(:authorize_ingress).with(:tcp, 22)

      stack.create_security_group
    end

    it "rescues and continues when exception for duplicate security group is raise" do
      aws_ec2.should_receive(:security_groups) { aws_ec2 }
      aws_ec2.should_receive(:create).with(security_group_name).and_raise(AWS::EC2::Errors::InvalidGroup::Duplicate)

      stack.create_security_group
    end
  end
end
