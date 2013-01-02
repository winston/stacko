require 'spec_helper'

describe Stacko::StandaloneInstance do

  let(:environment) { 'production' }
  let(:config) { Stacko::Configuration.new "#{File.dirname(__FILE__)}/../fixtures/stacko.standalone.yml", environment }
  subject(:standalone_instance) { Stacko::StandaloneInstance.new config }

  its(:ip_address){ should == config['env'][environment]['ip_address'] }
  its(:user_name){ should == config['env'][environment]['user_name'] }

end

describe Stacko::EC2Instance do

  let(:environment) { 'production' }
  let(:config) { Stacko::Configuration.new "#{File.dirname(__FILE__)}/../fixtures/stacko.aws.yml", environment }
  let(:ec2_host_config) { Stacko::EC2HostsConfiguration.new "#{File.dirname(__FILE__)}/../fixtures/dotstacko.yml", environment }

  subject(:ec2_instance) { Stacko::EC2Instance.new config, ec2_host_config }

  its(:ip_address){ should == ec2_host_config['ip_address'] }
  its(:user_name){ should  == 'ubuntu' }

end
