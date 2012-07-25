require 'spec_helper'

describe Stacko::EC2 do
  # Mocks
  let(:stack)               { Stacko::EC2.new(aws_config) }
  let(:aws_ec2)             { mock(:aws_ec2) }
  let(:key_pair)            { mock(:key_pair, private_key: "oh so private") }
  let(:security_group)      { mock(:security_group) }
  let(:file)                { StringIO.new }

  # Expectations
  let(:project)             { "stacko" }
  let(:aws_config) do
    {
      "access_key_id"     => "123",
      "secret_access_key" => "abc",
      "ec2_endpoint"      => "ec2.ap-southeast-1.amazonaws.com"
    }
  end
  let(:ec2_config) do
    {
      "image_id"          => "ami-1234",
      "instance_id"       => "m1.small"
    }
  end
  let(:key_name)            { project }
  let(:key_pair_filename)   { "/users/winston/.ec2/#{key_name}.pem" }
  let(:security_group_name) { "#{project}-web" }

  before { stub_const("ENV", {"HOME" => "/users/winston"}) }

  describe ".create" do
    let(:fake) { mock(:stack) }

    it "invokes the steps to create an EC2 instance" do
      Stacko::EC2.should_receive(:new).with(aws_config) { fake }
      fake.should_receive(:create_key_pair)
      fake.should_receive(:create_security_group)
      fake.should_receive(:create_instance).with(ec2_config)

      Stacko::EC2.create(aws_config, ec2_config)
    end

    it "raises exception when config is not complete" do

    end
  end

  describe "#initialize" do
    it "initializes AWS config with environment variables" do
      AWS::EC2.should_receive(:new).with(aws_config)

      Stacko::EC2.new(aws_config)
    end
  end

  describe "#create_key_pair" do
    before { AWS::EC2.should_receive(:new) { aws_ec2 } }

    it "creates a key pair and saves the private key to ~/.ec2/<project>.pem" do
      aws_ec2.should_receive(:key_pairs) { aws_ec2 }
      aws_ec2.should_receive(:create).with(key_name) { key_pair }

      File.should_receive(:open).with(key_pair_filename, "w").and_yield(file)

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

  describe "#create_instance" do
    before { AWS::EC2.should_receive(:new) { aws_ec2 } }

    it "creates a new instance on AWS" do
      aws_ec2.should_receive(:instances) { aws_ec2 }
      aws_ec2.should_receive(:create)
        .with( ec2_config.merge( { "key_name" => key_name, "security_groups" => security_group_name } ) )
        .and_return( mock(:instance, id: "instance", status: :running) )

      stack.should_receive(:save_to_yaml).with("instance")

      stack.create_instance(ec2_config)
    end
  end

end
