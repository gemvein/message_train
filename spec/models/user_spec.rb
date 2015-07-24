require 'rails_helper'

RSpec.describe User do

  describe 'Model' do
    # Rolify Gem by extension
    it { should have_and_belong_to_many(:roles) }

    # NightTrain Gem
    it { should have_many(:messages) }
    it { should have_many(:receipts) }
  end

  describe 'Scopes and Methods from Night Train' do
    include_context 'loaded site'

    describe '#conversations' do
      subject { first_user.conversations }
      its(:first) { should be_a NightTrain::Conversation }
      its(:count) { should be >= 5 }
    end

  end

end
