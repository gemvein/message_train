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
        subject { NightTrain::Message.find_by_subject('This should turn into a draft') }
        its(:receipts) { should have_exactly(1).items } # i.e. sender
        its(:recipients) { should be_empty }
        its(:draft) { should be true }
      end
    end
    describe 'Scopes and Methods' do
      context '.with_receipts_by' do
        subject { NightTrain::Message.with_receipts_by(first_user).first.conversation }
        it { should eq sent_conversation }
      end
      context '.with_receipts_to' do
        subject { NightTrain::Message.with_receipts_to(first_user).first.conversation }
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
    end
  end
end
