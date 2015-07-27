require 'rails_helper'

module NightTrain
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
        subject { NightTrain::Receipt.sender_receipt.first }
        its(:sender) { should be true }
      end
      describe '.recipient_receipt' do
        subject { NightTrain::Receipt.recipient_receipt.first }
        its(:sender) { should be false }
      end
      describe '.for' do
        subject { NightTrain::Receipt.for(first_user).conversations }
        it { should include sent_conversation }
        it { should include unread_conversation }
        it { should include ignored_conversation }
        it { should include trashed_conversation }
        it { should include read_conversation }
      end
      describe '.receipts_to' do
        subject { NightTrain::Receipt.receipts_to(first_user) }
        its(:first) { should be_a NightTrain::Receipt }
        its(:count) { should be > 5 }
      end
      describe '.trashed_to' do
        subject { NightTrain::Receipt.trashed_to(first_user).first.message.conversation }
        its(:subject) { should eq 'Trashed Conversation' }
      end
      describe '.untrashed_to' do
        subject { NightTrain::Receipt.untrashed_to(first_user).first }
        its(:marked_trash) { should be false }
      end
      describe '.read_to' do
        subject { NightTrain::Receipt.read_to(first_user).first.message.conversation }
        its(:subject) { should eq 'Read Conversation' }
      end
      describe '.deleted_to' do
        subject { NightTrain::Receipt.deleted_to(first_user).first.message.conversation }
        its(:subject) { should eq 'Deleted Conversation' }
      end
      describe '.undeleted_to' do
        subject { NightTrain::Receipt.undeleted_to(first_user).first }
        its(:marked_deleted) { should be false }
      end
      describe '.message_ids' do
        subject { NightTrain::Receipt.receipts_by(first_user).message_ids }
        it { should include sent_conversation.messages.first.id }
      end
      describe '.messages' do
        subject { NightTrain::Receipt.receipts_by(first_user).messages }
        it { should include sent_conversation.messages.first }
      end
    end
  end
end
