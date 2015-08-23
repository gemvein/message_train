require 'rails_helper'

module MessageTrain
  RSpec.describe Receipt do
    describe 'Model' do
      # Relationships
      it { should belong_to :message }
      it { should belong_to :recipient }
      # Validations
      it { should validate_presence_of :message }
      it { should validate_presence_of :recipient }
    end
    describe 'Scopes and Methods' do
      include_context 'loaded site'
      describe '.sender_receipt' do
        subject { MessageTrain::Receipt.sender_receipt.first }
        its(:sender) { should be true }
      end
      describe '.recipient_receipt' do
        subject { MessageTrain::Receipt.recipient_receipt.first }
        its(:sender) { should be false }
      end
      describe '.for' do
        subject { MessageTrain::Receipt.for(first_user).conversations }
        it { should include sent_conversation }
        it { should include unread_conversation }
        it { should include ignored_conversation }
        it { should include trashed_conversation }
        it { should include read_conversation }
      end
      describe '.receipts_to' do
        subject { MessageTrain::Receipt.receipts_to(first_user) }
        its(:first) { should be_a MessageTrain::Receipt }
        its(:count) { should be > 5 }
      end
      describe '.trashed_to' do
        subject { MessageTrain::Receipt.trashed_to(first_user).first.message.conversation }
        its(:subject) { should eq 'Trashed Conversation' }
      end
      describe '.untrashed_to' do
        subject { MessageTrain::Receipt.untrashed_to(first_user).first }
        its(:marked_trash) { should be false }
      end
      describe '.read_to' do
        subject { MessageTrain::Receipt.read_to(first_user).first.message.conversation }
        its(:subject) { should eq 'Read Conversation' }
      end
      describe '.deleted_to' do
        subject { MessageTrain::Receipt.deleted_to(first_user).first.message.conversation }
        its(:subject) { should eq 'Deleted Conversation' }
      end
      describe '.undeleted_to' do
        subject { MessageTrain::Receipt.undeleted_to(first_user).first }
        its(:marked_deleted) { should be false }
      end
      describe '.message_ids' do
        subject { MessageTrain::Receipt.receipts_by(first_user).message_ids }
        it { should include sent_conversation.messages.first.id }
      end
      describe '.messages' do
        subject { MessageTrain::Receipt.receipts_by(first_user).messages }
        it { should include sent_conversation.messages.first }
      end
      describe '#mark' do
        before do
          unread_conversation.messages.first.receipts.for(first_user).first.mark(:read)
        end
        subject { unread_conversation.messages.first.is_read_to?(first_user) }
        it { should be true }
      end
    end
  end
end
