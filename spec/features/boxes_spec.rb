require 'rails_helper'
RSpec.feature 'Boxes' do
  include_context 'loaded site'

  describe 'Showing' do
    describe 'at /box/in' do
      before do
        login_as first_user
        visit '/box/in'
      end
      it_behaves_like 'a bootstrap page listing a collection of items', NightTrain::Conversation, plural_title: 'Inbox', minimum: 2
    end
  end
  describe 'Marking', js: true do
    describe 'at /box/in' do
      describe 'without checking anything' do
        before do
          login_as first_user
          visit '/box/in'
          click_button 'Mark'
          click_link 'Mark as Read'
        end
        it_behaves_like 'a bootstrap page with an alert', 'warning', 'Nothing to do'
      end
      describe 'after checking a box' do
        describe 'Marking Read' do
          before do
            login_as first_user
            visit '/box/in'
            check "objects_conversations_#{unread_conversation.id.to_s}"
            click_button 'Mark'
            click_link 'Mark as Read'
          end
          it_behaves_like 'a bootstrap page with an alert', 'info', 'Update successful'
        end
        describe 'Marking Ignored' do
          before do
            login_as first_user
            visit '/box/in'
            check "objects_conversations_#{unread_conversation.id.to_s}"
            click_button 'Mark'
            click_link 'Mark as Ignored'
          end
          it_behaves_like 'a bootstrap page with an alert', 'info', 'Update successful'
        end
      end
    end
  end
end
