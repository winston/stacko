require 'spec_helper'
require 'debugger'

describe Stacko::Configuration do
  
  let(:environment) { 'production' }
  subject(:standalone_config) { Stacko::Configuration.new "#{File.dirname(__FILE__)}/../fixtures/stacko.standalone.yml", environment }

  its(:type) { should == "standalone" }

end
