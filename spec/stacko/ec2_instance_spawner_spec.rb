require 'spec_helper'

describe Stacko::EC2InstanceSpawner do
  include Stacko::Settings

  # Mocks
  let(:fake_aws_ec2)             { double(:fake_aws_ec2) }
  let(:fake_instance)            { double(:ec2_instance, id: "id-1234", ip_address: "127.0.0.1", status: :running, tags: {"environment" => environment}) }

  # Expectations
  let(:environment)         { "production" }
  let(:config) { Stacko::Configuration.new "#{File.dirname(__FILE__)}/../fixtures/stacko.aws.yml", environment }
  let(:load_config)         { YAML::load(File.read("#{File.dirname(__FILE__)}/../fixtures/dotstacko.yml")) }

  describe "#initialize" do
    it "initializes AWS config with environment variables" do
      AWS::EC2.should_receive(:new).with(config.global)
      Stacko::EC2InstanceSpawner.new config
    end
  end

  describe "interaction with AWS::EC2 API" do

    subject(:stack) { Stacko::EC2InstanceSpawner.new(config) }
    before { AWS::EC2.should_receive(:new).and_return fake_aws_ec2 }

    describe "#launch" do

      it "creates a new instance on AWS" do
        fake_aws_ec2.should_receive(:instances).and_return fake_aws_ec2
        fake_aws_ec2.should_receive(:create)
        .with(config.env.merge({"key_name" => 'key_name', "security_groups" => ['security_group_name']}))
        .and_return(fake_instance)

        fake_instance.should_receive(:tag).with("environment", {value: environment})

        stack.stub(:key_name).and_return('key_name')
        stack.stub(:security_group_name).and_return('security_group_name')
        stack.stub!(:sleep)
        stack.launch
      end
    end

    describe "#to_hash" do

      before do
        stack.instance_variable_set(:@instance, fake_instance)
      end

      it "returns a hash of details" do
        stack.to_hash.should == { environment => { "instance_id" => fake_instance.id, "ip_address" => fake_instance.ip_address } }
      end

    end
  end

end
