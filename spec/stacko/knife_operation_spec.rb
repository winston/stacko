require 'spec_helper'

shared_examples 'a knife command' do

  context 'has either a private key file or password or both' do

    after { knife_operation.send(knife_command) }

    context 'has a private key file only' do
      let(:instance) { double(username: 'Ben', ip_address: '127.0.0.1', private_key_file: '~/super_secret.key', private_key_file?: true, password?: false) }
      it { knife_operation.should_receive("system").with("knife #{knife_command} #{instance.username}@#{instance.ip_address} -i #{instance.private_key_file}") }
    end

    context 'has a password only' do
      let(:instance) { double(username: 'Ben', ip_address: '127.0.0.1', password: 'supersecret', private_key_file?: false, password?: true) }
      it { knife_operation.should_receive("system").with("knife #{knife_command} #{instance.username}@#{instance.ip_address} -P #{instance.password}") }
    end

    context 'has both a private key file and a password' do
      let(:instance) { double(username: 'Ben', ip_address: '127.0.0.1',  private_key_file: '~/super_secret.key', password: 'supersecret', private_key_file?: true, password?: true) }
      it { knife_operation.should_receive("system").with("knife #{knife_command} #{instance.username}@#{instance.ip_address} -i #{instance.private_key_file}") }
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
end
