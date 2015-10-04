require 'rails_helper'

module MessageTrain
  RSpec.describe Message do
    include_context 'loaded site'
    describe 'Model' do
      # Relationships
      it { should belong_to :conversation }
      it { should belong_to :sender }
      it { should have_many :attachments }
      it { should have_many :receipts }

      # Validations
      it { should validate_presence_of :sender }
      it { should validate_presence_of :subject }
    end
    describe 'Callbacks' do
      context 'sets draft to true on a message to no one' do
        subject { draft_conversation.messages.drafts.first }
        its(:sender) { should eq first_user }
        its(:receipts) { should have_exactly(1).item } # i.e. sender
        its(:recipients) { should be_empty }
        its(:draft) { should be true }
      end
      context 'generates receipts when present' do
        subject { sent_message }
        its(:sender) { should eq first_user }
        its(:receipts) { should have_exactly(2).items } # i.e. sender and recipient
        its(:recipients) { should include second_user }
        its(:draft) { should be false }
      end
    end
    describe 'Scopes and Methods' do
      context '.ready' do
        subject { MessageTrain::Message.ready.conversations }
        it { should include sent_conversation }
        it { should_not include draft_conversation }
      end
      context '.drafts' do
        subject { MessageTrain::Message.drafts.first.conversation }
        it { should eq draft_conversation }
      end
      context '.by' do
        subject { MessageTrain::Message.by(first_user) }
        it { should include sent_message }
        it { should include draft_message }
      end
      context '.drafts_by' do
        subject { MessageTrain::Message.drafts_by(first_user).first.conversation }
        it { should eq draft_conversation }
      end
      context '.with_receipts_by' do
        subject { MessageTrain::Message.with_receipts_by(first_user).last.conversation }
        it { should eq sent_conversation }
      end
      context '.with_receipts_to' do
        subject { MessageTrain::Message.with_receipts_to(first_user).last.conversation }
        it { should eq unread_conversation }
      end
      context '.with_trashed_to and #is_trashed_to?' do
        subject { trashed_conversation.messages.with_trashed_to(first_user).first.is_trashed_to?(first_user) }
        it { should be true }
      end
      context '.with_deleted_to and #is_deleted_to?' do
        subject { deleted_conversation.messages.with_deleted_to(first_user).first.is_deleted_to?(first_user) }
        it { should be true }
      end
      context '.with_read_to and #is_read_to?' do
        subject { read_conversation.messages.with_read_to(first_user).first.is_read_to?(first_user) }
        it { should be true }
      end
      context '.mark' do
        before do
          read_conversation.messages.mark(:trash, first_user)
        end
        subject { read_message.is_trashed_to?(first_user) }
        it { should be true }
      end
      context '#mark' do
        before do
          read_message.mark(:unread, first_user)
        end
        subject { read_message.is_read_to?(first_user) }
        it { should be false }
      end
      context '#recipients' do
        subject { unread_message.recipients.first }
        it { should eq first_user }
      end
      context '.conversation_ids' do
        subject { unread_conversation.messages.conversation_ids }
        its(:first) { should eq unread_conversation.id }
      end
      context '.conversations' do
        subject { unread_conversation.messages.conversations }
        its(:first) { should eq unread_conversation }
      end
    end
  end
end
