require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "NightTrain" do
  it 'should return correct version string' do
    NightTrain.version_string.should == "NightTrain version #{NightTrain::VERSION}"
  end
end
