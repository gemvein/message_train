require 'rails_helper'

RSpec.describe User do
  include_context 'loaded site'

  describe 'Model' do
    # Rolify Gem by extension
    it { should have_and_belong_to_many(:roles) }

    # MessageTrain Gem
    it { should have_many(:messages) }
    it { should have_many(:receipts) }
  end

  describe 'Scopes and Methods' do
    describe '#box' do
      subject { first_user.box }
      it { should be_a MessageTrain::Box }
      its(:division) { should be :in }
      its(:parent) { should be first_user }
      its(:participant) { should be first_user }
    end

    describe '#collective_boxes' do
      describe 'with 0 arguments' do
        subject do
          first_user.collective_boxes[:groups].collect(&:parent)
        end
        it { should include membered_group }
        it { should include first_group }
      end
      describe 'with 1 argument' do
        subject do
          first_user.collective_boxes(:in)[:groups].collect(&:parent)
        end
        it { should include membered_group }
        it { should include first_group }
      end
    end

    describe '#all_boxes' do
      describe 'with 0 arguments' do
        context 'returns all boxes for the given user' do
          subject { first_user.all_boxes }
          its(:first) { should be_a MessageTrain::Box }
          its(:count) { should be 6 }
        end
      end
      describe 'with 1 argument' do
        context 'returns all boxes for the given user' do
          subject { first_user.all_boxes(first_user) }
          its(:first) { should be_a MessageTrain::Box }
          its(:count) { should be 6 }
        end
      end
    end

    describe '#conversations' do
      context 'with division not set' do
        subject do
          first_user.conversations.first.includes_receipts_to?(first_user)
        end
        it { should be true }
      end
      context 'with division as :in' do
        subject do
          first_user.conversations(:in).first.includes_receipts_to?(first_user)
        end
        it { should be true }
      end
      context 'with division as :sent' do
        subject do
          first_user.conversations(:sent)
                    .first.includes_receipts_by?(first_user)
        end
        it { should be true }
      end
      context 'with division as :trash' do
        subject do
          first_user.conversations(:trash)
                    .first.includes_trashed_for?(first_user)
        end
        it { should be true }
      end
      context 'with impossible division' do
        subject { first_user.conversations(:impossible).nil? }
        it { should be true }
      end
    end

    describe '#all_conversations' do
      let(:required_conversations) do
        [
          sent_conversation,
          unread_conversation,
          read_conversation,
          ignored_conversation,
          trashed_conversation,
          deleted_conversation
        ]
      end
      describe 'with no arguments' do
        context 'returns all conversations with any receipt' do
          subject { first_user.all_conversations }
          it { should include(*required_conversations) }
          it { should_not include someone_elses_conversation }
        end
      end
      describe 'with 1 argument' do
        context 'returns all conversations with any receipt' do
          subject { first_user.all_conversations(first_user) }
          it { should include(*required_conversations) }
          it { should_not include someone_elses_conversation }
        end
      end
      context 'when empty' do
        subject { silent_user.all_conversations }
        it { should eq [] }
      end
    end

    describe '#all_messages' do
      let(:required_messages) do
        [
          sent_message,
          unread_message,
          read_message,
          ignored_message,
          trashed_message,
          deleted_message
        ]
      end
      describe 'with no arguments' do
        context 'returns all messages with any receipt' do
          subject { first_user.all_messages }
          it { should include(*required_messages) }
          it { should_not include someone_elses_message }
        end
      end
      describe 'with 1 argument' do
        context 'returns all messages with any receipt' do
          subject { first_user.all_messages(first_user) }
          it { should include(*required_messages) }
          it { should_not include someone_elses_message }
        end
      end
      context 'when empty' do
        subject { silent_user.all_messages }
        it { should eq [] }
      end
    end

    describe '#unsubscribed_from?' do
      describe 'when an unsubscribe exists' do
        subject { unsubscribed_user.unsubscribed_from?(membered_group) }
        it { should be true }
      end
      describe 'when no unsubscribe exists' do
        subject { first_user.unsubscribed_from?(membered_group) }
        it { should be false }
      end
      describe 'when unsubscribe_from is used' do
        before do
          first_user.unsubscribe_from(membered_group)
        end
        subject { first_user.unsubscribed_from?(membered_group) }
        it { should be true }
      end
    end

    describe '#message_train_subscriptions' do
      subject { first_user.message_train_subscriptions }
      it { should be_an Array }
      it { should have_at_least(3).items }
    end
  end
end
