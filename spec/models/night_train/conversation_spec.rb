require 'rails_helper'

module NightTrain
  RSpec.describe Conversation do
    describe 'Model' do
      it { should have_many :messages }
      it { should have_many :ignores }
      it { should have_many(:receipts).through(:messages) }
    end
    describe 'Scopes and Methods' do
      include_context 'loaded site'
      describe '#set_ignored and #is_ignored?' do
        subject { ignored_conversation.is_ignored?(first_user) }
        it { should be true }
      end
      describe '#set_unignored' do
        before do
          ignored_conversation.set_unignored(first_user)
        end
        subject { ignored_conversation.is_ignored?(first_user) }
        it { should be false }
      end
      describe '#mark and #includes_read_for?' do
        before do
          unread_conversation.mark(:read, first_user)
        end
        subject { unread_conversation.includes_read_for?(first_user) }
        it { should be true }
      end
      describe 'Dynamic Methods' do
        describe '.trashed_for' do
          subject { NightTrain::Conversation.with_trashed_for(first_user) }
          it { should include trashed_conversation }
        end
        describe '.untrashed_for' do
          subject { NightTrain::Conversation.with_untrashed_for(first_user) }
          it { should_not include trashed_conversation }
        end
        describe '.deleted_for' do
          subject { NightTrain::Conversation.with_deleted_for(first_user) }
          it { should include deleted_conversation }
        end
        describe '.undeleted_for' do
          subject { NightTrain::Conversation.with_undeleted_for(first_user) }
          it { should_not include deleted_conversation }
        end
        describe '.read_for' do
          subject { NightTrain::Conversation.with_read_for(first_user) }
          it { should include read_conversation }
        end
        describe '.unread_for' do
          subject { NightTrain::Conversation.with_unread_for(first_user) }
          it { should include sent_conversation }
          it { should include unread_conversation }
        end
        describe '#includes_trashed_to?' do
          subject { trashed_conversation.includes_trashed_to?(first_user) }
          it { should be true }
        end
        describe '#includes_read_to?' do
          subject { read_conversation.includes_read_to?(first_user) }
          it { should be true }
        end
        describe '#includes_deleted_to?' do
          subject { deleted_conversation.includes_deleted_to?(first_user) }
          it { should be true }
        end
        describe '#includes_receipts_to?' do
          subject { unread_conversation.includes_receipts_to?(first_user) }
          it { should be true }
        end
        describe '#includes_receipts_by?' do
          subject { sent_conversation.includes_receipts_by?(first_user) }
          it { should be true }
        end
        describe '#includes_receipts_for?' do
          subject { sent_conversation.includes_receipts_for?(first_user) }
          it { should be true }
        end
      end
    end
  end
end
