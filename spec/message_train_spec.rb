require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe 'MessageTrain' do
  it 'should return correct version string' do
    MessageTrain.version_string
                .should == "MessageTrain version #{MessageTrain::VERSION}"
  end
end
