require 'rails_helper'
RSpec.feature 'Messages' do
  include_context 'loaded site'

  it_behaves_like 'an authenticated section', '/messages/box/in/messages/new'

  describe 'When logged in' do
    before do
      login_as first_user
    end
    describe 'Drafting', js: true do
      describe 'at /box/in/messages' do
        before do
          visit '/messages/box/in/messages/new/'
          fill_in_autocomplete 'Recipients', with: 'x'
          fill_in 'Subject', with: 'This is a draft.'
          fill_in 'Body', with: 'This is the body.'
          submit_via_button 'Send'
          wait_until { page.has_css? '.alert' }
        end
        it_behaves_like(
          'a bootstrap page with an alert',
          'warning',
          'Message saved as draft.'
        )
      end
    end
    describe 'Composing', js: true do
      describe 'at /box/in/messages' do
        before do
          visit '/messages/box/in/messages/new/'
          fill_in_autocomplete 'Recipients', with: 'sec'
          fill_in 'Subject', with: 'This is the subject.'
          fill_in 'Body', with: 'This is the body.'
          click_button 'add-attachment'
          click_button 'add-attachment'
          click_button 'add-attachment'
          within '#attachments .message-train-attachment-fields:nth-child(1)' do
            attach_file 'Attachment', File.absolute_path(
              './spec/dummy/app/assets/files/message_train/attachments/'\
                'example.pdf'
            )
          end
          within '#attachments .message-train-attachment-fields:nth-child(2)' do
            attach_file 'Attachment', File.absolute_path(
              './spec/dummy/app/assets/files/message_train/attachments/'\
                'Bambisj.jpg'
            )
          end
          within '#attachments .message-train-attachment-fields:nth-child(3)' do
            accept_confirm do
              find('button').click
            end
          end
          submit_via_button 'Send'
          wait_until { page.has_css? '.alert' }
        end
        it_behaves_like(
          'a bootstrap page with an alert',
          'info',
          'Message sent.'
        )
      end
    end
    describe 'Editing a Draft', js: true do
      describe 'at /box/in/messages' do
        before do
          visit "/messages/box/in/conversations/#{draft_conversation.id}"
          fill_in_autocomplete 'Recipients', with: 'sec'
          fill_in 'Subject', with: 'This is the subject.'
          fill_in 'Body', with: 'This is the body.'
          submit_via_button 'Send'
          wait_until { page.has_css?('.alert') }
        end
        it 'shows a sent alert and no draft-saved alert' do
          expect(page).to have_selector(
            '#alert_area .alert.info', text: 'Message sent.'
          )
          expect(page).not_to have_selector('#alert_area .alert.warning')
        end
      end
    end
  end
end
