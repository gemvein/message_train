require 'rails_helper'
RSpec.feature 'Messages' do
  include_context 'loaded site'

  before do
    login_as first_user
  end
  describe 'Drafting' do
    describe 'at /box/in/messages' do
      before do
        visit '/box/in/messages/new/'
        fill_in 'User Recipients', with: '' # Being blank makes it a draft
        fill_in 'Subject', with: 'This is a draft.'
        fill_in 'Body', with: 'This is the body.'
        click_button 'Send'
      end
      it_behaves_like 'a bootstrap page with an alert', 'warning', 'Message saved as draft.'
    end
  end
  describe 'Composing' do
    describe 'at /box/in/messages' do
      before do
        visit '/box/in/messages/new/'
        fill_in 'User Recipients', with: 'second-user'
        fill_in 'Subject', with: 'This is the subject.'
        fill_in 'Body', with: 'This is the body.'
        click_button 'Send'
      end
      it_behaves_like 'a bootstrap page with an alert', 'info', 'Message sent.'
    end
  end
  describe 'Editing a Draft' do
    describe 'at /box/in/messages' do
      before do
        visit "/box/in/conversations/#{draft_conversation.id}"
        fill_in 'User Recipients', with: 'second-user'
        fill_in 'Subject', with: 'This is the subject.'
        fill_in 'Body', with: 'This is the body.'
        find(:css, "#message_draft").set(false)
        click_button 'Send'
      end
      it_behaves_like 'a bootstrap page with an alert', 'info', 'Message sent.'
      it_behaves_like 'a bootstrap page without an alert', 'warning'
    end
  end
end
