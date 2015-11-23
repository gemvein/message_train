require 'rails_helper'
RSpec.feature 'Messages' do
  include_context 'loaded site'
  include Wysihtml5Helper

  before do
    login_as first_user
  end
  describe 'Drafting', js: true do
    describe 'at /box/in/messages' do
      before do
        visit '/box/in/messages/new/'
        recipient_input = find(:css, "#message_recipients_to_save_users .tags-input")
        recipient_input.set("")
        fill_in 'Subject', with: 'This is a draft.'
        fill_in_html 'Body', with: 'This is the body.'
        click_button 'Send'
      end
      it_behaves_like 'a bootstrap page with an alert', 'warning', 'Message saved as draft.'
    end
  end
  describe 'Composing', js: true do
    describe 'at /box/in/messages' do
      before do
        visit '/box/in/messages/new/'
        recipient_input = find(:css, "#message_recipients_to_save_users .tags-input")
        recipient_input.set("sec") # Should auto-complete to second-user with the following two key-presses
        recipient_input.native.send_keys :arrow_down
        recipient_input.native.send_keys :return
        fill_in 'Subject', with: 'This is the subject.'
        fill_in_html 'Body', with: 'This is the body.'
        click_link 'add-attachment'
        click_link 'add-attachment'
        click_link 'add-attachment'
        within '#attachments .nested-fields:nth-child(1)' do
          attach_file 'Attachment', File.absolute_path('./spec/dummy/app/assets/files/message_train/attachments/example.pdf')
        end
        within '#attachments .nested-fields:nth-child(2)' do
          attach_file 'Attachment', File.absolute_path('./spec/dummy/app/assets/files/message_train/attachments/Bambisj.jpg')
        end
        within '#attachments .nested-fields:nth-child(3)' do
          accept_confirm do
            find('.remove_fields').click
          end
        end
        click_button 'Send'
      end
      it_behaves_like 'a bootstrap page with an alert', 'info', 'Message sent.'
    end
  end
  describe 'Editing a Draft', js: true do
    describe 'at /box/in/messages' do
      before do
        visit "/box/in/conversations/#{draft_conversation.id}"
        recipient_input = find(:css, "#message_recipients_to_save_users .tags-input")
        recipient_input.set("sec") # Should auto-complete to second-user with the following two key-presses
        recipient_input.native.send_keys :arrow_down
        recipient_input.native.send_keys :return
        fill_in 'Subject', with: 'This is the subject.'
        fill_in_html 'Body', with: 'This is the body.'
        click_button 'Send'
      end
      it_behaves_like 'a bootstrap page with an alert', 'info', 'Message sent.'
      it_behaves_like 'a bootstrap page without an alert', 'warning'
    end
  end
end
