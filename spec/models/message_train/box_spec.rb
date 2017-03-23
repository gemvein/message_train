require 'rails_helper'

module MessageTrain
  RSpec.describe Box do
    include_context 'loaded site'
    let(:user_in_box) { first_user.box(:in) }
    let(:user_sent_box) { first_user.box(:sent) }
    let(:user_trash_box) { first_user.box(:trash) }
    let(:user_all_box) { first_user.box(:all) }
    let(:user_drafts_box) { first_user.box(:drafts) }
    let(:user_ignored_box) { first_user.box(:ignored) }
    let(:owned_group_box) do
      first_user.collective_boxes[:groups].find do |x|
        x.parent.slug == 'first-group'
      end
    end
    let(:membered_group_box) do
      first_user.collective_boxes[:groups].find do |x|
        x.parent.slug == 'membered-group'
      end
    end

    describe 'Scopes and Methods' do
      describe '#unread_count' do
        subject { user_in_box.unread_count }
        it { should be >= 2 }
      end

      describe '#conversations' do
        context 'with division as :in' do
          subject { user_in_box.conversations }
          it { should_not include sent_conversation }
          it { should include unread_conversation }
          it { should include read_conversation }
          it { should_not include ignored_conversation }
          it { should_not include trashed_conversation }
          it { should_not include deleted_conversation }
          it { should_not include draft_conversation }
        end
        context 'with division as :sent' do
          subject { user_sent_box.conversations }
          it { should include sent_conversation }
          it { should_not include unread_conversation }
          it { should_not include read_conversation }
          it { should_not include ignored_conversation }
          it { should_not include trashed_conversation }
          it { should_not include deleted_conversation }
          it { should_not include draft_conversation }
        end
        context 'with division as :trash' do
          subject { user_trash_box.conversations }
          it { should_not include sent_conversation }
          it { should_not include unread_conversation }
          it { should_not include read_conversation }
          it { should_not include ignored_conversation }
          it { should include trashed_conversation }
          it { should_not include deleted_conversation }
          it { should_not include draft_conversation }
        end
        context 'with division as :drafts' do
          subject { user_drafts_box.conversations }
          it { should_not include sent_conversation }
          it { should_not include trashed_conversation }
          it { should_not include read_conversation }
          it { should_not include unread_conversation }
          it { should_not include deleted_conversation }
          it { should_not include ignored_conversation }
          it { should include draft_conversation }
        end
        context 'with unread set to true' do
          subject { user_in_box.conversations(unread: true) }
          it { should_not include sent_conversation }
          it { should include unread_conversation }
          it { should_not include read_conversation }
          it { should_not include ignored_conversation }
          it { should_not include trashed_conversation }
          it { should_not include deleted_conversation }
          it { should_not include draft_conversation }
        end
      end

      describe '#find_conversation' do
        subject { user_in_box.find_conversation(unread_conversation.id) }
        it { should eq unread_conversation }
      end

      describe '#find_message' do
        subject { user_in_box.find_message(unread_message.id) }
        it { should eq unread_message }
      end

      describe '#send_message' do
        describe 'to a singular recipient' do
          let(:message) do
            {
              recipients_to_save: { 'users' => 'second-user' },
              subject: 'Message to send',
              body: '...'
            }
          end
          subject { user_in_box.send_message(message) }
          it { should be_a MessageTrain::Message }
        end
        describe 'to a collective recipient' do
          describe 'when recipient does not accept from sender' do
            context 'message status' do
              let(:message) do
                {
                  recipients_to_save: { 'groups' => 'membered-group' },
                  subject: 'Message to send',
                  body: '...'
                }
              end
              subject { membered_group_box.send_message(message) }
              it { should be false }
            end
            context 'box status' do
              let(:message) do
                {
                  recipients_to_save: { 'groups' => 'membered-group' },
                  subject: 'Message to send',
                  body: '...'
                }
              end
              before do
                membered_group_box.send_message(message)
              end
              subject do
                membered_group_box.errors.all.find do |x|
                  x[:css_id] == 'message_train_message'
                end
              end
              its([:message]) { should eq 'Invalid sender for Group 2' }
            end
          end
          describe 'when recipient accepts from sender' do
            let(:message) do
              {
                recipients_to_save: { 'groups' => 'first-group' },
                subject: 'Message to send',
                body: '...'
              }
            end
            subject { owned_group_box.send_message(message) }
            it { should be_a MessageTrain::Message }
          end
        end
      end

      describe '#update_message' do
        describe 'to a singular recipient' do
          let(:message) do
            {
              recipients_to_save: { 'users' => 'second-user' },
              subject: 'Message to send',
              body: '...',
              draft: false
            }
          end
          subject { user_in_box.update_message(draft_message, message) }
          it { should be_a MessageTrain::Message }
        end
        describe 'to a collective recipient' do
          describe 'when recipient does not accept from sender' do
            context 'message status' do
              let(:message) do
                {
                  recipients_to_save: { 'groups' => 'membered-group' },
                  subject: 'Message to send',
                  body: '...',
                  draft: false
                }
              end
              subject do
                membered_group_box.update_message(
                  owned_group_draft.messages.first,
                  message
                )
              end
              it { should be false }
            end
            context 'box status' do
              let(:message) do
                {
                  recipients_to_save: { 'groups' => 'membered-group' },
                  subject: 'Message to send', body: '...', draft: false
                }
              end
              let(:owned_group_draft_id) { owned_group_draft.messages.first.id }
              before do
                membered_group_box.update_message(
                  owned_group_draft.messages.first,
                  message
                )
              end
              subject do
                membered_group_box.errors.all.find do |x|
                  x[:css_id] == "message_train_message_#{owned_group_draft_id}"
                end
              end
              its([:message]) do
                should eq "Access to Message #{owned_group_draft_id} denied"
              end
            end
          end
          describe 'when recipient accepts from sender' do
            let(:message) do
              {
                recipients_to_save: { 'groups' => 'first-group' },
                subject: 'Message to send',
                body: '...',
                draft: false
              }
            end
            subject do
              owned_group_box.update_message(
                owned_group_draft.messages.first,
                message
              )
            end
            it { should be_a MessageTrain::Message }
          end
        end
      end

      describe '#title' do
        context 'with division set to :in' do
          subject { user_in_box.title }
          it { should eq 'Inbox' }
        end
        context 'with division set to :sent' do
          subject { user_sent_box.title }
          it { should eq 'Sent' }
        end
        context 'with division set to :all' do
          subject { user_all_box.title }
          it { should eq 'All' }
        end
        context 'with division set to :drafts' do
          subject { user_drafts_box.title }
          it { should eq 'Drafts' }
        end
        context 'with division set to :trash' do
          subject { user_trash_box.title }
          it { should eq 'Trash' }
        end
        context 'with division set to :ignored' do
          subject { user_ignored_box.title }
          it { should eq 'Ignored' }
        end
      end

      describe '#mark' do
        context 'when not present' do
          it 'raises an ActiveRecord::RecordNotFound error' do
            expect do
              last_user.box.mark('read', conversations: ['99999999'])
            end.to(
              raise_error(
                ActiveRecord::RecordNotFound,
                /Couldn't find MessageTrain::Conversation/
              )
            )
          end
        end
        context 'when bad type' do
          before do
            last_user.box.mark('read', users: [first_user.id.to_s])
          end
          subject { last_user.box.errors.all.first[:message] }
          it { should match(/Cannot mark users/) }
        end
        context 'when bad object' do
          describe 'given singular box' do
            before do
              last_user.box.mark('read', conversations: Time.now)
            end
            subject { last_user.box.errors.all.first[:message] }
            it { should match(/Cannot mark with Time/) }
          end
          describe 'given collective box' do
            # This test is mostly here to test the error handling for collective
            # boxes, not so much the mark method
            before do
              first_group.box(:in, first_user)
                         .mark('read', conversations: Time.now)
            end
            subject { first_group.box(:in, first_user).errors.all }
            it do
              should eq [
                {
                  css_id: 'box',
                  path: '/collectives/groups:first-group/box/in',
                  message: 'Cannot mark with Time'
                }
              ]
            end
          end
        end
        context 'when not authorized' do
          before do
            last_user.box.mark('unread', conversations: read_conversation)
          end
          subject { last_user.box.errors.all.first[:message] }
          it { should match(/Access to Conversation ([0-9]+) denied/) }
        end
        context 'when authorized' do
          before do
            user_in_box.mark(
              'unread',
              conversations: [read_conversation.id.to_s]
            )
          end
          subject { read_conversation.includes_read_for?(first_user) }
          it { should be false }
        end
      end

      describe '#message' do
        describe 'when there are errors' do
          let(:message) do
            {
              recipients_to_save: { 'users' => 'second-user' },
              subject: ''
            }
          end
          before do
            first_user.box.send_message(message)
          end
          subject { first_user.box.message }
          it { should eq "Subject can't be blank" }
        end
        describe 'when there are results' do
          let(:message) do
            {
              recipients_to_save: { 'users' => 'second-user' },
              subject: 'Valid'
            }
          end
          before do
            first_user.box.send_message(message)
          end
          subject { first_user.box.message }
          it { should eq 'Message sent.' }
        end
        describe 'when there is nothing to do' do
          subject { first_user.box.message }
          it { should eq 'Nothing to do' }
        end
      end

      describe '#send_message' do
        context 'when message is valid' do
          let(:valid_attributes) do
            {
              recipients_to_save: { 'users' => 'second-user, third-user' },
              subject: 'Test Message',
              body: 'This is the content.'
            }
          end
          subject { user_in_box.send_message(valid_attributes) }
          it { should be_a MessageTrain::Message }
          its(:new_record?) { should be false }
          its('errors.full_messages.to_sentence') { should eq '' }
          its(:recipients) { should include second_user }
          its(:recipients) { should include third_user }
          its(:draft) { should be false }
        end
        context 'when message is invalid' do
          let(:invalid_attributes) do
            {
              recipients_to_save: { 'users' => 'second-user, third-user' },
              subject: nil,
              body: 'This is the content.'
            }
          end
          subject { user_in_box.send_message(invalid_attributes) }
          it { should be_a_new MessageTrain::Message }
          its('errors.full_messages.to_sentence') do
            should eq "Subject can't be blank"
          end
          its(:recipients) { should be_empty }
        end
      end

      describe '#update_message' do
        describe 'when message is valid' do
          context 'and still a draft' do
            let(:valid_attributes) do
              {
                recipients_to_save: { 'users' => 'second-user, third-user' },
                subject: 'Test Message',
                body: 'This is the content.',
                draft: true
              }
            end
            subject do
              user_in_box.update_message(draft_message, valid_attributes)
            end
            it { should be_a MessageTrain::Message }
            its('errors.full_messages.to_sentence') { should eq '' }
            its(:recipients) { should be_empty }
            its(:subject) { should eq 'Test Message' }
            its(:draft) { should be true }
          end
          context 'and no longer a draft' do
            let(:valid_attributes) do
              {
                recipients_to_save: { 'users' => 'second-user, third-user' },
                subject: 'Test Message',
                body: 'This is the content.',
                draft: false
              }
            end
            subject do
              user_in_box.update_message(draft_message, valid_attributes)
            end
            it { should be_a MessageTrain::Message }
            its('errors.full_messages.to_sentence') { should eq '' }
            its(:recipients) { should include second_user }
            its(:recipients) { should include third_user }
            its(:subject) { should eq 'Test Message' }
            its(:draft) { should be false }
          end
        end
        context 'when message is invalid' do
          let(:invalid_attributes) do
            {
              recipients_to_save: { 'users' => 'second-user, third-user' },
              subject: '',
              body: 'This is the content.',
              draft: false
            }
          end
          subject do
            user_in_box.update_message(draft_message, invalid_attributes)
          end
          it { should be_a MessageTrain::Message }
          its('errors.full_messages.to_sentence') do
            should eq "Subject can't be blank"
          end
          its(:recipients) { should be_empty }
        end
      end

      describe '#authorize' do
        describe 'given participant is the same as parent' do
          describe 'when bad type' do
            before do
              first_user.box.authorize(second_user)
            end
            subject { first_user.box.errors.all }
            it do
              should eq(
                [
                  css_id: 'user',
                  path: nil,
                  message: 'Cannot authorize User'
                ]
              )
            end
          end
          describe 'when conversation' do
            describe 'is authorized' do
              subject { first_user.box.authorize(unread_conversation) }
              it { should be true }
            end
            describe 'is not authorized' do
              subject { first_user.box.authorize(someone_elses_conversation) }
              it { should be false }
            end
          end
          describe 'when message' do
            describe 'is authorized' do
              subject { first_user.box.authorize(unread_message) }
              it { should be true }
            end
            describe 'is not authorized' do
              subject { first_user.box.authorize(someone_elses_message) }
              it { should be false }
            end
          end
        end
        describe 'given parent differs from participant' do
          # This is really here to test the error handling for this case.
          describe 'when message' do
            describe 'is authorized' do
              subject do
                first_group.box(:in, first_user).authorize(group_message)
              end
              it { should be true }
            end
            describe 'is not authorized' do
              describe 'result' do
                subject do
                  membered_group.box(:in, third_user).authorize(
                    membered_group_message
                  )
                end
                it { should be false }
              end
              describe 'box status' do
                before do
                  membered_group.box(:in, third_user).authorize(
                    membered_group_message
                  )
                end
                subject { membered_group.box(:in, third_user).errors.all }
                it do
                  should(
                    eq [
                      {
                        css_id: 'message_train_message_'\
                          "#{membered_group_message.id}",
                        path: '/collectives/groups:membered-group/box/in/'\
                          "messages/#{membered_group_message.id}",
                        message: 'Access to Message '\
                          "#{membered_group_message.id} denied"
                      }
                    ]
                  )
                end
              end
            end
          end
        end
      end
    end
  end
end
