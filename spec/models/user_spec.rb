require 'rails_helper'

RSpec.describe User do

  describe 'Model' do
    # Rolify Gem by extension
    it { should have_and_belong_to_many(:roles) }

    # NightTrain Gem
    it { should have_many(:messages) }
    it { should have_many(:receipts) }
  end

  describe 'Scopes and Methods' do
    include_context 'loaded site'

    describe '#conversations' do
      context 'with division as :in' do
        subject { first_user.conversations(:in).first.includes_receipts_to?(first_user) }
        it { should be true }
      end
      context 'with division as :sent' do
        subject { first_user.conversations(:sent).first.includes_receipts_by?(first_user) }
        it { should be true }
      end
      context 'with division as :trash' do
        subject { first_user.conversations(:trash).first.includes_trashed_for?(first_user) }
        it { should be true}
      end
    end

  end

end
