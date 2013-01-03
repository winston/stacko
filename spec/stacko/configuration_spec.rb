require 'spec_helper'

describe Stacko::Configuration do

  let(:environment) { 'production' }
  subject(:standalone_config) { Stacko::Configuration.new "#{File.dirname(__FILE__)}/../fixtures/stacko.standalone.yml", environment }

  its(:type) { should == "standalone" }

  describe "#validate_yaml" do

    subject(:config_validate_yaml) { standalone_config.validate_config_keys config_hash, required_keys }

    context 'when all the required keys are provided' do

      let(:config_hash) { {'key1' => 'key1', 'key2' => 'key2', 'key3' => 'key3'} }
      let(:required_keys) { %w{key1 key2} }

      it { expect { config_validate_yaml }.to_not raise_error }
    end

    context 'raises an error when any of the required keys are not provided' do

      let(:config_hash) { {'key1' => 'key1', 'key3' => 'key3'} }
      let(:required_keys) {  %w{key1 key2} }

      it { expect { config_validate_yaml }.to raise_error }

    end

    context 'raises an error if the required configuration is empty' do

      let(:config_hash) { {'key1' => 'key1', 'key2' => '', 'key3' => 'key3'} }
      let(:required_keys) {  %w{key1 key2} }

      it { expect { config_validate_yaml }.to raise_error }
    end

  end
end
