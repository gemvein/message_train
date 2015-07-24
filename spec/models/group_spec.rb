require 'rails_helper'

RSpec.describe Group do
  describe 'Model' do
    # NightTrain Gem, and Rolify Gem by extension
    it { should have_many(:roles) }
    
    # NightTrain Gem
    it { should have_many(:receipts) }
  end

  describe 'Scopes and Methods from Night Train' do
    include_context 'loaded site'

    describe '#conversations' do
      subject { first_group.conversations }
      its(:first) { should be_a NightTrain::Conversation }
      its(:count) { should eq 1 }
    end

  end

end
