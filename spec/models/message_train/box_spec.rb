require 'rails_helper'

module MessageTrain
  RSpec.describe Box do
    describe 'Model' do

    end
    describe 'Scopes and Methods' do
      include_context 'loaded site'

      describe '#unread_count' do
        subject { first_user.box.unread_count }
        it { should be >= 2 }
      end
      describe '#conversations' do
        context 'with division as :in' do
          subject { first_user.box.conversations }
          it { should_not include sent_conversation }
          it { should include unread_conversation }
          it { should include read_conversation }
          it { should_not include ignored_conversation }
          it { should_not include trashed_conversation }
          it { should_not include deleted_conversation }
          it { should_not include draft_conversation }
        end
        context 'with division as :sent' do
          subject { first_user.box(:sent).conversations }
          it { should include sent_conversation }
          it { should_not include unread_conversation }
          it { should_not include read_conversation }
          it { should_not include ignored_conversation }
          it { should_not include trashed_conversation }
          it { should_not include deleted_conversation }
          it { should_not include draft_conversation }
        end
        context 'with division as :trash' do
          subject { first_user.box(:trash).conversations }
          it { should_not include sent_conversation }
          it { should_not include unread_conversation }
          it { should_not include read_conversation }
          it { should_not include ignored_conversation }
          it { should include trashed_conversation }
          it { should_not include deleted_conversation }
          it { should_not include draft_conversation }
        end
        context 'with division as :drafts' do
          subject { first_user.box(:drafts).conversations }
          it { should_not include sent_conversation }
          it { should_not include trashed_conversation }
          it { should_not include read_conversation }
          it { should_not include unread_conversation }
          it { should_not include deleted_conversation }
          it { should_not include ignored_conversation }
          it { should include draft_conversation }
        end
        context 'with unread set to true' do
          subject { first_user.box.conversations(unread: true) }
          it { should_not include sent_conversation }
          it { should include unread_conversation }
          it { should_not include read_conversation }
          it { should_not include ignored_conversation }
          it { should_not include trashed_conversation }
          it { should_not include deleted_conversation }
          it { should_not include draft_conversation }
        end
      end
      describe '#ignore' do
        context 'when authorized' do
          before do
            first_user.box.ignore(read_conversation)
          end
          subject { read_conversation.is_ignored?(first_user) }
          it { should be true}
        end
        context 'when not authorized' do
          before do
            last_user.box.ignore(read_conversation)
          end
          subject { last_user.box.errors.all.first[:message] }
          it { should match /Access to Conversation ([0-9]+) denied/ }
        end
      end
      describe '#unignore' do
        context 'when authorized' do
          before do
            first_user.box.unignore(ignored_conversation)
          end
          subject { ignored_conversation.is_ignored?(first_user) }
          it { should be false }
        end
        context 'when not authorized' do
          before do
            last_user.box.unignore(read_conversation)
          end
          subject { last_user.box.errors.all.first[:message] }
          it { should match /Access to Conversation ([0-9]+) denied/ }
        end
      end
      describe '#title' do
        context 'with division set to :in' do
          subject { first_user.box.title }
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
        context 'with division set to :drafts' do
          subject { first_user.box(:drafts).title }
          it { should eq 'Drafts' }
        end
        context 'with division set to :trash' do
          subject { first_user.box(:trash).title }
          it { should eq 'Trash' }
        end
      end
      describe '#mark' do
        before do
          first_user.box.mark('unread', conversations: [read_conversation.id.to_s])
        end
        subject { read_conversation.includes_read_for?(first_user) }
        it { should be false }
      end
      describe '.send_message' do
        context 'when message is valid' do
          let(:valid_attributes) { { recipients_to_save: {'users' => 'second-user, third-user'}, subject: 'Test Message', body: 'This is the content.' } }
          subject { first_user.box.send_message(valid_attributes) }
          it { should be_a MessageTrain::Message }
          its(:new_record?) { should be false }
          its('errors.full_messages.to_sentence') { should eq '' }
          its(:recipients) { should include second_user }
          its(:recipients) { should include third_user }
          its(:draft) { should be false }
        end
        context 'when message is invalid' do
          let(:invalid_attributes) { { recipients_to_save: {'users' => 'second-user, third-user'}, subject: nil, body: 'This is the content.' } }
          subject { first_user.box.send_message(invalid_attributes) }
          it { should be_a_new MessageTrain::Message }
          its('errors.full_messages.to_sentence') { should eq "Subject can't be blank" }
          its(:recipients) { should be_empty }
        end
      end
      describe '.update_message' do
        let(:draft_message) { draft_conversation.messages.first }
        context 'when message is valid' do
          let(:valid_attributes) { {
              recipients_to_save: {'users' => 'second-user, third-user'},
              subject: 'Test Message',
              body: 'This is the content.',
              draft: false
          } }
          subject { first_user.box.update_message(draft_message, valid_attributes) }
          it { should be_a MessageTrain::Message }
          its('errors.full_messages.to_sentence') { should eq '' }
          its(:recipients) { should include second_user }
          its(:recipients) { should include third_user }
          its(:subject) { should eq 'Test Message' }
          its(:draft) { should be false }
        end
        context 'when message is invalid' do
          let(:invalid_attributes) { {
              recipients_to_save: {'users' => 'second-user, third-user'},
              subject: '',
              body: 'This is the content.',
              draft: false
          } }
          subject { first_user.box.update_message(draft_message, invalid_attributes) }
          it { should be_a MessageTrain::Message }
          its('errors.full_messages.to_sentence') { should eq "Subject can't be blank" }
          its(:recipients) { should be_empty }
        end
      end

      describe '.new_message' do
        context 'when conversation is set' do
          let(:expected_recipients) { { 'users' => 'second-user' } }
          subject { first_user.box.new_message(conversation_id: unread_conversation.id) }
          it { should be_a_new MessageTrain::Message }
          its(:subject) { should eq 'Re: Unread Conversation' }
          its(:recipients_to_save) { should eq expected_recipients }
        end
        context 'when conversation is not set' do
          subject { first_user.box.new_message }
          it { should be_a_new MessageTrain::Message }
          its(:subject) { should eq nil }
          its(:recipients_to_save) { should be_empty }
        end
      end
    end
  end
end
