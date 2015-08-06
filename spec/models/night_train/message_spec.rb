require 'rails_helper'

module NightTrain
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
    end
    describe 'Scopes and Methods' do
      context '.drafts' do
        subject { NightTrain::Message.drafts.first.conversation }
        it { should eq draft_conversation }
      end
      context '.by' do
        subject { NightTrain::Message.by(first_user) }
        it { should include sent_conversation.messages.first }
        it { should include draft_conversation.messages.first }
      end
      context '.drafts_by' do
        subject { NightTrain::Message.drafts_by(first_user).first.conversation }
        it { should eq draft_conversation }
      end
      context '.with_receipts_by' do
        subject { NightTrain::Message.with_receipts_by(first_user).last.conversation }
        it { should eq sent_conversation }
      end
      context '.with_receipts_to' do
        subject { NightTrain::Message.with_receipts_to(first_user).last.conversation }
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
        subject { read_conversation.messages.first.is_trashed_to?(first_user) }
        it { should be true }
      end
      context '#mark' do
        before do
          read_conversation.messages.first.mark(:unread, first_user)
        end
        subject { read_conversation.messages.first.is_read_to?(first_user) }
        it { should be false }
      end
    end
  end
end
