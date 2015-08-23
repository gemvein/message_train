require 'rails_helper'
RSpec.feature 'Boxes' do
  include_context 'loaded site'

  before do
    login_as first_user
  end
  describe 'Showing' do
    describe 'at /box/in' do
      before do
        visit '/box/in'
      end
      it_behaves_like 'a bootstrap page listing a collection of items', MessageTrain::Conversation, plural_title: 'Inbox', minimum: 2
    end
  end
  describe 'Marking', js: true do
    describe 'at /box/in' do
      describe 'without checking anything' do
        before do
          visit '/box/in'
          click_button 'Mark'
          click_link 'mark-read'
        end
        it_behaves_like 'a bootstrap page with an alert', 'warning', 'Nothing to do'
      end
      describe 'after checking a box' do
        describe 'Marking Read' do
          before do
            visit '/box/in'
            click_link 'Last'
            check "objects_conversations_#{unread_conversation.id.to_s}"
            click_button 'Mark'
            click_link 'mark-read'
          end
          it_behaves_like 'a bootstrap page with an alert', 'info', 'Update successful'
        end
        describe 'Marking Ignored' do
          before do
            visit '/box/in'
            click_link 'Last'
            check "objects_conversations_#{unread_conversation.id.to_s}"
            click_button 'Mark'
            click_link 'mark-ignored'
          end
          it_behaves_like 'a bootstrap page with an alert', 'info', 'Update successful'
        end
      end
    end
  end
end
