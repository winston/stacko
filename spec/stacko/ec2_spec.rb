require 'spec_helper'

describe Stacko::EC2 do
  describe "initialize" do
    it "initializes AWS config with environment variables" do
      stub_const("ENV", {"AWS_ACCESS_KEY_ID" => "123", "AWS_SECRET_ACCESS_KEY" => "abc"})

      AWS::EC2.should_receive(:new).with({access_key_id: "123", secret_access_key: "abc"})
      Stacko::EC2.new
    end

    it "fails when environment variables are missing" do
      stub_const("ENV", {})

      expect { Stacko::EC2.new }.to raise_exception(AWS::Errors::MissingCredentialsError)
    end
  end

  describe "create_key_pair" do
    let(:stack)     { stack = Stacko::EC2.new }
    let(:aws_ec2)   { mock(:aws_ec2) }
    let(:key_pair)  { mock(:key_pair, private_key: "oh so private") }
    let(:file)      { StringIO.new }

    before do
      stub_const("ENV", {"AWS_ACCESS_KEY_ID" => "123", "AWS_SECRET_ACCESS_KEY" => "abc"})
      AWS::EC2.should_receive(:new) { aws_ec2 }
    end

    it "creates a key pair and saves the private key to ~/.ec2/<project_name>.pem" do
      aws_ec2.should_receive(:key_pairs) { aws_ec2 }
      aws_ec2.should_receive(:create).with("stacko") { key_pair }
      File.should_receive(:open).with("~/.ec2/stacko.pem", "w").and_yield(file)

      stack.create_key_pair
      file.string.should == key_pair.private_key
    end
  end

  describe "create_security_group" do
    it "creates a new security group <project_name>-web" do
      
    end  
  end

end
