require 'rails_helper'
RSpec.feature 'Conversations' do
  include_context 'loaded site'

  it_behaves_like 'an authenticated section', '/messages/box/in/conversations/1'

  describe 'When logged in' do
    before do
      login_as first_user
    end
    describe 'Showing' do
      describe 'at /box/in/conversations/:id' do
        before do
          visit "/messages/box/in/conversations/#{unread_conversation.id}"
        end
        it_behaves_like(
          'a bootstrap page showing an item',
          MessageTrain::Conversation,
          'Unread Conversation'
        )

        describe 'shows a reply link' do
          before do
            click_link 'Reply'
          end
          it_behaves_like 'a bootstrap page', title: 'Reply'
        end
      end
    end
    describe 'Marking', js: true do
      describe 'at /box/in/conversations/:id' do
        describe 'Marking Read' do
          before do
            visit "/messages/box/in/conversations/#{unread_conversation.id}"
            # An earlier example may have already marked this message read;
            # toggle it back to unread first so this test always exercises
            # (and can assert on) the read-marking action itself.
            click_button "mark_unread_#{unread_message.id}" if page.has_button?("mark_unread_#{unread_message.id}")
            click_button "mark_read_#{unread_message.id}"
          end
          after { undo_leaked_mark(:unread) }
          it_behaves_like(
            'a bootstrap page with an alert',
            'info',
            'Update successful'
          )
        end
        describe 'Marking Ignored' do
          before do
            visit "/messages/box/in/conversations/#{unread_conversation.id}"
            click_button 'Mark as Unignored' if page.has_button?('Mark as Unignored')
            accept_confirm do
              click_button 'Mark as Ignored'
            end
          end
          after { undo_leaked_mark(:unignore) }
          it_behaves_like(
            'a bootstrap page with an alert',
            'info',
            'Update successful'
          )
        end
      end
    end
  end
end
