require 'rails_helper'

module NightTrain
  RSpec.describe Box do
    describe 'Model' do

    end
    describe 'Scopes and Methods' do
      include_context 'loaded site'

      describe '#conversations' do
        context 'with division set to :in' do
          subject { first_user.conversations(:in).first.includes_receipts_to?(first_user) }
          it { should be true }
        end
        context 'with division as :sent' do
          subject { first_user.conversations(:sent).first.includes_receipts_by?(first_user) }
          it { should be true }
        end
        context 'with division as :trash' do
          subject { first_user.conversations(:trash).first.includes_trashed_for?(first_user) }
          it { should be true }
        end
      end
    end
  end
end
