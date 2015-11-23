require 'rails_helper'
RSpec.feature 'Conversations' do
  include_context 'loaded site'

  before do
    login_as first_user
  end
  describe 'Showing' do
    describe 'at /box/in/conversations/:id' do
      before do
        visit '/box/in/conversations/' + unread_conversation.id.to_s
      end
      it_behaves_like 'a bootstrap page showing an item', MessageTrain::Conversation, 'Unread Conversation'

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
          visit '/box/in/conversations/' + unread_conversation.id.to_s
          click_link "mark_read_#{unread_message.id.to_s}"
        end
        it_behaves_like 'a bootstrap page with an alert', 'info', 'Update successful'
      end
      describe 'Marking Ignored' do
        before do
          visit '/box/in/conversations/' + unread_conversation.id.to_s
          accept_confirm do
            click_link 'Mark as Ignored'
          end
        end
        it_behaves_like 'a bootstrap page with an alert', 'info', 'Update successful'
      end
    end
  end
end
