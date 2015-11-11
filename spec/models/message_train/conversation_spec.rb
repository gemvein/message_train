require 'rails_helper'

module MessageTrain
  RSpec.describe Conversation do
    include_context 'loaded site'

    describe 'Model' do
      it { should have_many :messages }
      it { should have_many :ignores }
      it { should have_many(:receipts).through(:messages) }
      it { should have_many(:attachments).through(:messages) }
    end

    describe 'Scopes and Methods' do

      describe '.ignored' do
        let(:results) { MessageTrain::Conversation.ignored(first_user) }
        subject { results.first.is_ignored?(first_user) }
        it { should be true }
      end

      describe '.unignored' do
        let(:results) { MessageTrain::Conversation.unignored(first_user) }
        subject { results.first.is_ignored?(first_user) }
        it { should be false }
      end

      describe '.with_drafts_by' do
        subject { MessageTrain::Conversation.with_drafts_by(first_user) }
        it { should include draft_conversation }
      end

      describe '.with_ready_for' do
        subject { MessageTrain::Conversation.with_ready_for(first_user) }
        it { should include unread_conversation }
      end

      describe '.with_messages_for' do
        subject { MessageTrain::Conversation.with_messages_for(first_user) }
        it { should include unread_conversation }
      end

      describe '.with_messages_through' do
        subject { MessageTrain::Conversation.with_messages_through(first_group) }
        it { should include group_conversation }
      end

      describe '#default_recipients_for' do
        subject { sent_conversation.default_recipients_for(first_user) }
        it { should include second_user }
        it { should_not include first_user }
        it { should_not include third_user }
      end

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

      describe '#includes_drafts_by?' do
        subject { draft_conversation.includes_drafts_by?(first_user) }
        it { should be true }
      end

      describe 'Dynamic Methods' do
        describe '.trashed_for' do
          subject { MessageTrain::Conversation.with_trashed_for(first_user) }
          it { should include trashed_conversation }
        end
        describe '.untrashed_for' do
          subject { MessageTrain::Conversation.with_untrashed_for(first_user) }
          it { should_not include trashed_conversation }
        end
        describe '.deleted_for' do
          subject { MessageTrain::Conversation.with_deleted_for(first_user) }
          it { should include deleted_conversation }
        end
        describe '.undeleted_for' do
          subject { MessageTrain::Conversation.with_undeleted_for(first_user) }
          it { should_not include deleted_conversation }
        end
        describe '.read_for' do
          subject { MessageTrain::Conversation.with_read_for(first_user) }
          it { should include read_conversation }
        end
        describe '.unread_for' do
          subject { MessageTrain::Conversation.with_unread_for(first_user) }
          it { should include sent_conversation }
          it { should include unread_conversation }
        end
        describe '#includes_trashed_to?' do
          subject { trashed_conversation.includes_trashed_to?(first_user) }
          it { should be true }
        end
        describe '#includes_ready_by?' do
          subject { sent_conversation.includes_ready_by?(first_user) }
          it { should be true }
        end
        describe '#includes_ready_to?' do
          subject { unread_conversation.includes_ready_to?(first_user) }
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
        describe '.find_by_subject' do
          # Testing super on method_missing
          subject { MessageTrain::Conversation.find_by_subject('Unread Conversation') }
          it { should be_a(MessageTrain::Conversation) }
        end
        describe '.with_ready_by' do
          subject { MessageTrain::Conversation.with_ready_by(first_user) }
          it { should include sent_conversation }
          it { should_not include draft_conversation }
          it { should_not include unread_conversation }
        end
        describe '.with_ready_to' do
          subject { MessageTrain::Conversation.with_ready_to(first_user) }
          it { should_not include sent_conversation }
          it { should_not include draft_conversation }
          it { should include unread_conversation }
        end
        describe '.with_messages_by' do
          subject { MessageTrain::Conversation.with_messages_by(first_user) }
          it { should include sent_conversation }
          it { should include draft_conversation }
          it { should_not include unread_conversation }
        end
      end

    end
  end
end
