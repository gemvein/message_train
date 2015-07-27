require 'rails_helper'

module NightTrain
  RSpec.describe Box do
    describe 'Model' do

    end
    describe 'Scopes and Methods' do
      include_context 'loaded site'

      describe '#conversations' do
        context 'with division set to :in' do
          subject { first_user.box.conversations(division: :in).first.includes_receipts_to?(first_user) }
          it { should be true }
        end
        context 'with division as :sent' do
          subject { first_user.box.conversations(division: :sent).first.includes_receipts_by?(first_user) }
          it { should be true }
        end
        context 'with division as :trash' do
          subject { first_user.box.conversations(division: :trash).first.includes_trashed_for?(first_user) }
          it { should be true }
        end
        context 'with division as :trash_and_all' do
          subject { first_user.box.conversations(division: :trash_and_all) }
          it { should include sent_conversation }
          it { should include trashed_conversation }
          it { should include read_conversation }
          it { should include unread_conversation }
        end
        context 'with unread set to true' do
          subject { first_user.box.conversations(division: :in, unread: true).first.includes_unread_for?(first_user) }
          it { should be true }
        end
      end
    end
  end
end
