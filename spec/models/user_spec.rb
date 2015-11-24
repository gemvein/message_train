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
      describe 'with valid number of arguments' do
        subject { first_user.box }
        it { should be_a MessageTrain::Box }
        its(:division) { should be :in }
        its(:parent) { should be first_user }
        its(:participant) { should be first_user }
      end
      describe 'with invalid number of arguments' do
        it "should raise" do
          expect{ first_user.box(:in, first_user, 'extra argument') }.to raise_error(RuntimeError, "Wrong number of arguments for User (expected 0..2, got 3)")
        end
      end
    end

    describe '#collective_boxes' do
      describe 'with 0 arguments' do
        subject { first_user.collective_boxes[:groups].collect { |x| x.parent } }
        it { should include membered_group }
        it { should include first_group }
      end
      describe 'with 1 argument' do
        subject { first_user.collective_boxes(:in)[:groups].collect { |x| x.parent } }
        it { should include membered_group }
        it { should include first_group }
      end
      describe 'with 3 arguments' do
        it "should raise" do
          expect{ first_user.collective_boxes(:in, first_user, 'extra argument') }.to raise_error(RuntimeError, "Wrong number of arguments for User (expected 0..2, got 3)")
        end
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
      describe 'with 2 arguments' do
        it "should raise" do
          expect{ first_user.all_boxes(first_user, 'extra argument') }.to raise_error(RuntimeError, "Wrong number of arguments for User (expected 0..1, got 2)")
        end
      end
    end

    describe '#conversations' do
      context 'with division not set' do
        subject { first_user.conversations.first.includes_receipts_to?(first_user) }
        it { should be true }
      end
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
      describe 'with 23 arguments' do
        it "should raise" do
          expect{ first_user.conversations(:in, first_user, 'extra argument') }.to raise_error(RuntimeError, "Wrong number of arguments for User (expected 0..2, got 3)")
        end
      end
      context 'with impossible division' do
        subject { first_user.conversations(:impossible).nil? }
        it { should be true}
      end
    end

    describe '#all_conversations' do
      describe 'with no arguments' do
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
      describe 'with 1 argument' do
        context 'returns all conversations with any receipt' do
          subject { first_user.all_conversations(first_user) }
          it { should include sent_conversation }
          it { should include unread_conversation }
          it { should include read_conversation }
          it { should include ignored_conversation }
          it { should include trashed_conversation }
          it { should include deleted_conversation }
          it { should_not include someone_elses_conversation }
        end
      end
      describe 'with 2 arguments' do
        it "should raise" do
          expect{ first_user.all_conversations(first_user, 'extra argument') }.to raise_error(RuntimeError, "Wrong number of arguments for User (expected 0..1, got 2)")
        end
      end
      context 'when empty' do
        subject { silent_user.all_conversations }
        it { should eq [] }
      end
    end

    describe '#all_messages' do
      describe 'with no arguments' do
        context 'returns all messages with any receipt' do
          subject { first_user.all_messages }
          it { should include sent_message }
          it { should include unread_message }
          it { should include read_message }
          it { should include ignored_message }
          it { should include trashed_message }
          it { should include deleted_message }
          it { should_not include someone_elses_message }
        end
      end
      describe 'with 1 argument' do
        context 'returns all messages with any receipt' do
          subject { first_user.all_messages(first_user) }
          it { should include sent_message }
          it { should include unread_message }
          it { should include read_message }
          it { should include ignored_message }
          it { should include trashed_message }
          it { should include deleted_message }
          it { should_not include someone_elses_message }
        end
      end
      describe 'with 2 arguments' do
        it "should raise" do
          expect{ first_user.all_messages(first_user, 'extra argument') }.to raise_error(RuntimeError, "Wrong number of arguments for User (expected 0..1, got 2)")
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
  end

end
