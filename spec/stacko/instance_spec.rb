require 'spec_helper'

shared_examples 'an introspectable instance' do

   describe '#private_key_file?' do

     before { instance.stub(private_key_file: "#{File.dirname(__FILE__)}/../fixtures/dummy_secret.key") }

     context 'private_key_file exists' do
       it 'should return true' do
         instance.private_key_file?.should be_true
       end
     end

     context "no private_key_file" do

       before { instance.stub(private_key_file: nil) }

       it 'should return false' do
         instance.private_key_file?.should be_false
       end
     end

   end

   describe '#password?' do

      context 'password exists' do

        before { instance.stub(password: 'password') }

        it 'should return true' do
          instance.password?.should be_true
        end
      end

      context "no password" do

        before { instance.stub(password: '') }

        it 'should return false' do
          instance.password?.should be_false
        end
      end

    end

end

shared_examples '#password' do

   context 'configuration has a password attribute' do

     let(:environment) { 'staging' }

     it 'should return true' do
       instance.password.should == config.env['password']
     end
   end

   context 'configuration does not have a password attribute' do

     it 'should return false' do
       instance.password.should == ''
     end
   end

end

describe Stacko::StandaloneInstance do

  subject(:standalone_instance) { Stacko::StandaloneInstance.new config }
  let(:environment) { 'production' }
  let(:config) { Stacko::Configuration.new "#{File.dirname(__FILE__)}/../fixtures/stacko.standalone.yml", environment }

  its(:ip_address){ should == config['env'][environment]['ip_address'] }
  its(:username){ should == config['env'][environment]['username'] }

  describe '#private_key_file' do

    context 'configuration has a private_key_file attribute' do

      it 'should return the private key file' do
        standalone_instance.private_key_file.should == config.env['private_key_file']
      end

    end

    context 'configuration does not have a private_key_file attribute' do

      let(:environment) { 'staging' }

      it 'should return a blank string' do
        standalone_instance.private_key_file.should == ''
      end
    end
  end

  it_behaves_like 'an introspectable instance' do
    let(:instance) { standalone_instance }
  end

  it_behaves_like '#password' do
    let(:instance) { standalone_instance }
  end
end

describe Stacko::EC2Instance do

  let(:environment) { 'production' }
  let(:config) { Stacko::Configuration.new "#{File.dirname(__FILE__)}/../fixtures/stacko.ec2.yml", environment }
  let(:ec2_host_config) { Stacko::EC2HostsConfiguration.new "#{File.dirname(__FILE__)}/../fixtures/dotstacko.yml", environment }

  subject(:ec2_instance) { Stacko::EC2Instance.new config, ec2_host_config }

  its(:ip_address){ should == ec2_host_config['ip_address'] }
  its(:username){ should  == 'ubuntu' }

  it_behaves_like 'an introspectable instance' do
    let(:instance) { ec2_instance }
  end

  it_behaves_like '#password' do
    let(:instance) { ec2_instance }
  end

end
