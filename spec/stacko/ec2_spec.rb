require 'spec_helper'

describe Stacko::EC2 do
  # Mocks
  let(:stack)               { stack = Stacko::EC2.new }
  let(:aws_ec2)             { mock(:aws_ec2) }
  let(:key_pair)            { mock(:key_pair, private_key: "oh so private") }
  let(:security_group)      { mock(:security_group) }
  let(:file)                { StringIO.new }

  # Expectations
  let(:project)             { "stacko" }
  let(:access_key_id)       { "123" }
  let(:secret_access_key)   { "abc" }
  let(:ec2_endpoint)        { "ec2.ap-southeast-1.amazonaws.com" }
  let(:image_id)            { "ami-1234" }
  let(:instance_type)       { "m1.micro" }
  let(:key_name)            { project }
  let(:key_pair_filename)   { "/users/winston/.ec2/#{key_name}.pem" }
  let(:security_group_name) { "#{project}-web" }

  before { stub_const("ENV", {"HOME" => "/users/winston", "AWS_ACCESS_KEY_ID" => access_key_id, "AWS_SECRET_ACCESS_KEY" => secret_access_key, "EC2_URL" => ec2_endpoint}) }

  describe "initialize" do
    it "initializes AWS config with environment variables" do
      AWS::EC2.should_receive(:new).with({access_key_id: access_key_id, secret_access_key: secret_access_key, ec2_endpoint: ec2_endpoint})

      stack
    end

    it "fails when environment variables are missing" do
      stub_const("ENV", {})

      expect { stack }.to raise_exception(AWS::Errors::MissingCredentialsError)
    end
  end

  describe "create_key_pair" do
    before { AWS::EC2.should_receive(:new) { aws_ec2 } }

    it "creates a key pair and saves the private key to ~/.ec2/<project>.pem" do
      aws_ec2.should_receive(:key_pairs) { aws_ec2 }
      aws_ec2.should_receive(:create).with(key_name) { key_pair }

      File.should_receive(:open).with(key_pair_filename, "w").and_yield(file)

      stack.create_key_pair
      file.string.should == key_pair.private_key
    end
  end

  describe "create_security_group" do
    before { AWS::EC2.should_receive(:new) { aws_ec2 } }

    it "creates a new security group <project_name>-web, and adds ingress traffic for HTTP, SSH and ICMP" do
      aws_ec2.should_receive(:security_groups) { aws_ec2 }
      aws_ec2.should_receive(:create).with(security_group_name) { security_group }

      security_group.should_receive(:allow_ping)
      security_group.should_receive(:authorize_ingress).with(:tcp, 80)
      security_group.should_receive(:authorize_ingress).with(:tcp, 22)

      stack.create_security_group
    end
  end

  describe "create_instance" do
    before { AWS::EC2.should_receive(:new) { aws_ec2 } }

    it "creates a new instance on AWS" do
      aws_ec2.should_receive(:instances) { aws_ec2 }
      aws_ec2.should_receive(:create).with({
        image_id: image_id,
        instance_type: instance_type,
        key_name: key_name,
        security_groups: security_group_name
      })

      stack.create_instance(image_id, instance_type)
    end

  end

end
