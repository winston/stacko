require 'spec_helper'

describe Stacko::Configuration do
  let(:environment) { 'production' }
  
  subject(:standalone_config) { Stacko::Configuration.new "#{File.dirname(__FILE__)}/../fixtures/stacko.standalone.yml", environment }

  its(:type) { should == "standalone" }

  describe "#validate_yaml" do
    let(:config_validate_yaml) { standalone_config.validate_config_keys config_hash, required_keys }

    context 'when all the required keys are provided' do
      let(:config_hash) { {'key1' => 'key1', 'key2' => 'key2', 'key3' => 'key3'} }
      let(:required_keys) { %w{key1 key2} }

      it { expect { config_validate_yaml }.to_not raise_error  } 
    end
    
    context 'raises an error when config is blank' do
      let(:config_hash) { nil }
      let(:required_keys) {  %w{key1} }

      it { expect { config_validate_yaml }.to raise_error("Empty config provided") }
    end      

    context 'raises an error when any of the required keys is not provided' do
      let(:config_hash) { {'key1' => 'key1', 'key3' => 'key3'} }
      let(:required_keys) {  %w{key1 key2} }

      it { expect { config_validate_yaml }.to raise_error('Missing required config attributes: ["key2"]') }
    end

    context 'raises an error when any of the required keys has an empty value' do
      let(:config_hash) { {'key1' => 'key1', 'key2' => '', 'key3' => 'key3'} }
      let(:required_keys) {  %w{key1 key2} }

      it { expect { config_validate_yaml }.to raise_error('Missing required config attributes: ["key2"]') }
    end
  end
end
