require 'rails_helper'

RSpec.describe Role do
  describe 'Model' do
    # MessageTrain Gem
    it { should have_many(:receipts) }
  end

  describe 'Scopes and Methods from Message Train' do
    include_context 'loaded site'

    describe '#slug_part' do
      subject { superadmin_role.slug_part }
      it { should eq 'superadmin' }
    end

    describe '#path_part' do
      subject { superadmin_role.path_part }
      it { should eq 'roles:superadmin' }
    end

    describe '#valid_senders' do
      subject { superadmin_role.valid_senders }
      it { should include superadmin_user }
      it { should_not include admin_user }
    end

    describe '#allows_sending_by?' do
      context 'when user is a superadmin' do
        subject { admin_role.allows_sending_by?(superadmin_user) }
        it { should be true }
      end
      context 'when user is not an owner' do
        subject { admin_role.allows_sending_by?(admin_user) }
        it { should be false }
      end
    end

    describe '#valid_recipients' do
      subject { admin_role.valid_recipients }
      it { should_not include first_user }
      it { should include admin_user }
    end

    describe '#allows_receiving_by?' do
      context 'when user is a member' do
        subject { admin_role.allows_receiving_by?(admin_user) }
        it { should be true }
      end
      context 'when user is not a member' do
        subject { admin_role.allows_receiving_by?(first_user) }
        it { should be false }
      end
    end

    describe '#self_collection' do
      subject { admin_role.self_collection }
      it { should be_a ActiveRecord::Relation }
      it { should eq [admin_role] }
    end

    describe '#conversations' do
      subject { admin_role.conversations(:in, admin_user) }
      its(:first) { should be_a MessageTrain::Conversation }
      its(:count) { should eq 1 }
    end

    describe '#boxes_for_participant' do
      context 'when participant is a valid sender' do
        subject do
          admin_role.boxes_for_participant(superadmin_user).collect(&:division)
        end
        it { should_not include :in }
        it { should include :sent }
        it { should include :drafts }
        it { should include :all }
        it { should include :trash }
        it { should_not include :ignored }
      end
      context 'when participant is a valid recipient' do
        subject do
          admin_role.boxes_for_participant(admin_user).collect(&:division)
        end
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
        subject { admin_role.all_conversations(superadmin_user) }
        its(:first) { should be_a MessageTrain::Conversation }
        it { should_not include unread_conversation }
        it { should include role_conversation }
        # Because received_through not set on sender receipts
        it { should_not include role_draft }
      end
      context 'when participant is a valid recipient' do
        subject { admin_role.all_conversations(admin_user) }
        its(:first) { should be_a MessageTrain::Conversation }
        it { should_not include unread_conversation }
        it { should include role_conversation }
        it { should_not include role_draft }
      end
    end

    describe '#all_messages' do
      context 'when participant is a valid sender' do
        subject { admin_role.all_messages(superadmin_user) }
        its(:first) { should be_a MessageTrain::Message }
        it { should_not include unread_message }
        it { should include role_message }
        # Because received_through not set on sender receipts
        it { should_not include role_draft_message }
      end
      context 'when participant is a valid recipient' do
        subject { admin_role.all_messages(admin_user) }
        its(:first) { should be_a MessageTrain::Message }
        it { should_not include unread_message }
        it { should include role_message }
        it { should_not include role_draft_message }
      end
    end
  end
end
