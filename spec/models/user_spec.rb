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

    describe '#all_conversations' do
      context 'returns all conversations with any receipt' do
        subject { first_user.all_conversations }
        it { should include sent_conversation }
        it { should include unread_conversation }
        it { should include read_conversation }
        it { should include ignored_conversation }
        it { should include trashed_conversation }
        it { should include deleted_conversation }
        it { should_not include someone_elses_conversation }
      end
    end

    describe '#all_messages' do
      context 'returns all messages with any receipt' do
        subject { first_user.all_messages }
        it { should include sent_conversation.messages.first }
        it { should include unread_conversation.messages.first }
        it { should include read_conversation.messages.first }
        it { should include ignored_conversation.messages.first }
        it { should include trashed_conversation.messages.first }
        it { should include deleted_conversation.messages.first }
        it { should_not include someone_elses_conversation.messages.first }
      end
    end

  end

end
