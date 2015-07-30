require 'rails_helper'

module NightTrain
  RSpec.describe Box do
    describe 'Model' do

    end
    describe 'Scopes and Methods' do
      include_context 'loaded site'

      describe '#unread_count' do
        subject { first_user.box(:in).unread_count }
        it { should be >= 2 }
      end
      describe '#conversations' do
        context 'with division as :in' do
          subject { first_user.box(:in).conversations }
          it { should_not include sent_conversation }
          it { should include unread_conversation }
          it { should include read_conversation }
          it { should_not include ignored_conversation }
          it { should_not include trashed_conversation }
          it { should_not include deleted_conversation }
        end
        context 'with division as :sent' do
          subject { first_user.box(:sent).conversations }
          it { should include sent_conversation }
          it { should_not include unread_conversation }
          it { should_not include read_conversation }
          it { should_not include ignored_conversation }
          it { should_not include trashed_conversation }
          it { should_not include deleted_conversation }
        end
        context 'with division as :trash' do
          subject { first_user.box(:trash).conversations }
          it { should_not include sent_conversation }
          it { should_not include unread_conversation }
          it { should_not include read_conversation }
          it { should_not include ignored_conversation }
          it { should include trashed_conversation }
          it { should_not include deleted_conversation }
        end
        context 'with division as :trash_and_all' do
          subject { first_user.box(:trash_and_all).conversations }
          it { should include sent_conversation }
          it { should include trashed_conversation }
          it { should include read_conversation }
          it { should include unread_conversation }
          it { should_not include deleted_conversation }
          it { should_not include ignored_conversation }
        end
        context 'with unread set to true' do
          subject { first_user.box(:in).conversations(unread: true) }
          it { should_not include sent_conversation }
          it { should include unread_conversation }
          it { should_not include read_conversation }
          it { should_not include ignored_conversation }
          it { should_not include trashed_conversation }
          it { should_not include deleted_conversation }
        end
      end
      describe '#ignore' do
        before do
          first_user.box(:in).ignore(read_conversation)
        end
        subject { read_conversation.is_ignored?(first_user) }
        it { should be true}
      end
      describe '#unignore' do
        before do
          first_user.box(:in).unignore(ignored_conversation)
        end
        subject { ignored_conversation.is_ignored?(first_user) }
        it { should be false }
      end
      describe '#title' do
        context 'with division set to :in' do
          subject { first_user.box(:in).title }
          it { should eq 'Inbox' }
        end
        context 'with division set to :sent' do
          subject { first_user.box(:sent).title }
          it { should eq 'Sent Messages' }
        end
        context 'with division set to :all' do
          subject { first_user.box(:all).title }
          it { should eq 'All Messages' }
        end
        context 'with division set to :trash_and_all' do
          subject { first_user.box(:trash_and_all).title }
          it { should eq 'All Messages (Including Trash)' }
        end
        context 'with division set to :trash' do
          subject { first_user.box(:trash).title }
          it { should eq 'Trash' }
        end
      end
      describe '#mark' do
        before do
          first_user.box(:in).mark('unread', conversations: [read_conversation.id.to_s])
        end
        subject { read_conversation.includes_read_for?(first_user) }
        it { should be false }
      end
    end
  end
end
