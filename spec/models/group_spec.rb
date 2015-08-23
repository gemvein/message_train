require 'rails_helper'

RSpec.describe Group do
  describe 'Model' do
    # MessageTrain Gem, and Rolify Gem by extension
    it { should have_many(:roles) }
    
    # MessageTrain Gem
    it { should have_many(:receipts) }
  end

  describe 'Scopes and Methods from Message Train' do
    include_context 'loaded site'

    describe '#conversations' do
      subject { first_group.conversations(:in) }
      its(:first) { should be_a MessageTrain::Conversation }
      its(:count) { should eq 1 }
    end

  end

end
