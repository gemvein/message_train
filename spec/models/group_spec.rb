require 'rails_helper'

RSpec.describe Group do
  describe 'Model' do
    # MessageTrain Gem, and Rolify Gem by extension
    it { should have_many(:roles) }
    
    # MessageTrain Gem
    it { should have_many(:receipts) }
  end

  describe 'Scopes and Methods from Message Train' do
    include_context 'loaded site'

    describe '#slug_part' do
      subject { membered_group.slug_part }
      it { should eq 'membered-group' }
    end

    describe '#path_part' do
      subject { membered_group.path_part }
      it { should eq 'groups:membered-group' }
    end

    describe '#valid_senders' do
      subject { membered_group.valid_senders }
      it { should include second_user }
      it { should_not include first_user }
    end

    describe '#allows_sending_by?' do
      context 'when user is an owner' do
        subject { membered_group.allows_sending_by?(second_user) }
        it { should be true }
      end
      context 'when user is not an owner' do
        subject { membered_group.allows_sending_by?(first_user) }
        it { should be false }
      end
    end

    describe '#valid_recipients' do
      subject { membered_group.valid_recipients }
      it { should_not include second_user }
      it { should include first_user }
    end

    describe '#allows_receiving_by?' do
      context 'when user is a member' do
        subject { membered_group.allows_receiving_by?(first_user) }
        it { should be true }
      end
      context 'when user is not a member' do
        subject { membered_group.allows_receiving_by?(second_user) }
        it { should be false }
      end
    end

    describe '#self_collection' do
      subject { membered_group.self_collection }
      it { should be_a ActiveRecord::Relation }
      it { should include membered_group }
      it { should have_exactly(1).item }
    end

    describe '#conversations' do
      subject { membered_group.conversations(:in, first_user) }
      its(:first) { should be_a MessageTrain::Conversation }
      its(:count) { should eq 4 }
    end

    describe '#boxes_for_participant' do
      context 'when participant is a valid sender' do
        subject { membered_group.boxes_for_participant(second_user).collect { |x| x.division } }
        it { should_not include :in }
        it { should include :sent }
        it { should include :drafts }
        it { should include :all }
        it { should include :trash }
        it { should_not include :ignored }
      end
      context 'when participant is a valid recipient' do
        subject { membered_group.boxes_for_participant(first_user).collect { |x| x.division } }
        it { should include :in }
        it { should_not include :sent }
        it { should_not include :drafts }
        it { should include :all }
        it { should include :trash }
        it { should include :ignored }
      end
    end

    describe '#all_conversations' do
      context 'when participant is a valid sender' do
        subject { membered_group.all_conversations(second_user) }
        its(:first) { should be_a MessageTrain::Conversation }
        it { should_not include unread_conversation }
        it { should include membered_group_conversation }
        it { should_not include membered_group_draft } # Because received_through not set on sender receipts
      end
      context 'when participant is a valid recipient' do
        subject { membered_group.all_conversations(first_user) }
        its(:first) { should be_a MessageTrain::Conversation }
        it { should_not include unread_conversation }
        it { should include membered_group_conversation }
        it { should_not include membered_group_draft }
      end
    end

    describe '#all_messages' do
      context 'when participant is a valid sender' do
        subject { membered_group.all_messages(second_user) }
        its(:first) { should be_a MessageTrain::Message }
        it { should_not include unread_message }
        it { should include membered_group_message }
        it { should_not include membered_group_draft.messages.first } # Because received_through not set on sender receipts
      end
      context 'when participant is a valid recipient' do
        subject { membered_group.all_messages(first_user) }
        its(:first) { should be_a MessageTrain::Message }
        it { should_not include unread_message }
        it { should include membered_group_message }
        it { should_not include membered_group_draft.messages.first }
      end
    end

  end

end
