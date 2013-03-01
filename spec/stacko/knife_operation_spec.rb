require 'spec_helper'

shared_examples 'a knife command' do

  context 'has either a private key file or password or both' do

    after { knife_operation.send(knife_command) }

    context 'has a private key file only' do
      let(:instance) { double(username: 'Ben', ip_address: '127.0.0.1', private_key_file: '~/super_secret.key', private_key_file?: true, password?: false, environment: 'production') }
      it { knife_operation.should_receive("system").with("knife solo #{knife_command} #{instance.username}@#{instance.ip_address} -i #{instance.private_key_file} nodes/#{instance.environment}.json") }
    end

    context 'has a password only' do
      let(:instance) { double(username: 'Ben', ip_address: '127.0.0.1', password: 'supersecret', private_key_file?: false, password?: true, environment: 'production') }
      it { knife_operation.should_receive("system").with("knife solo #{knife_command} #{instance.username}@#{instance.ip_address} -P #{instance.password} nodes/#{instance.environment}.json") }
    end

    context 'has both a private key file and a password' do
      let(:instance) { double(username: 'Ben', ip_address: '127.0.0.1',  private_key_file: '~/super_secret.key', password: 'supersecret', private_key_file?: true, password?: true, environment: 'production') }
      it { knife_operation.should_receive("system").with("knife solo #{knife_command} #{instance.username}@#{instance.ip_address} -i #{instance.private_key_file} nodes/#{instance.environment}.json") }
    end

  end

  context 'has neither a private key file nor a password' do
    let(:instance) { double(username: 'Ben', ip_address: '127.0.0.1', private_key_file?: false, password?: false) }
    it { expect { knife_operation.send(knife_command) }.to raise_error }
  end
end

describe Stacko::KnifeOperation do

  subject(:knife_operation) { Stacko::KnifeOperation.new instance }

  describe "#prepare" do

    it_behaves_like 'a knife command' do
      let(:knife_command) {'prepare'}
    end

  end

  describe "#cook" do

    it_behaves_like 'a knife command' do
      let(:knife_command) {'cook'}
    end

  end

  describe '#init' do
    let(:instance) { double(username: 'Ben', ip_address: '127.0.0.1',  private_key_file: '~/super_secret.key', password: 'supersecret', private_key_file?: true, password?: true) }
    it 'invokes knife solo init' do
      knife_operation.should_receive("system").with("knife solo init .")
      knife_operation.init
    end

    it 'creates placeholders for the config files' do
      FileUtils.should_receive('mkdir_p').with('.chef')
      FileUtils.should_receive('touch').with('.chef/knife.rb')
      knife_operation.init
    end
  end
end
