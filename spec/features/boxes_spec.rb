require 'rails_helper'
RSpec.feature 'Boxes' do
  include_context 'loaded site'

  it_behaves_like 'an authenticated section', '/box'
  it_behaves_like(
    'an authenticated section',
    '/collectives/groups:membered-group'
  )

  describe 'When logged in as first-user' do
    before do
      login_as first_user
    end
    describe 'Without a collective' do
      describe 'Showing' do
        describe 'at /box/in' do
          before do
            visit '/box/in'
            click_link 'Last'
          end
          it_behaves_like(
            'a bootstrap page listing a collection of items',
            MessageTrain::Conversation,
            plural_title: 'Inbox',
            minimum: 1
          )

          describe 'does not list Roles dropdown' do
            subject { page }
            it do
              should_not have_css(
                'li.dropdown a.dropdown-toggle',
                text: 'Roles'
              )
            end
          end

          describe 'shows the attachment icon on the correct conversation' do
            before do
              if page.has_no_css?(
                "#message_train_conversation_#{attachment_conversation.id}"
              )
                click_link 'Prev'
              end
            end
            subject { page }
            it do
              should have_css(
                "#message_train_conversation_#{attachment_conversation.id} "\
                  '.glyphicon-paperclip'
              )
            end
          end

          describe 'shows a link to compose' do
            before do
              within '.content' do
                find('.compose').click
              end
            end
            it_behaves_like 'a bootstrap page', title: 'New Message'
          end
        end
      end

      describe 'Marking', js: true do
        describe 'at /box/in' do
          describe 'using the buttons on each conversation' do
            before do
              visit '/box/in'
              click_link 'Last'
              find(
                "#message_train_conversation_#{unread_conversation.id}"
              ).hover
              within "#message_train_conversation_#{unread_conversation.id}" do
                accept_confirm do
                  find('.trash-toggle').click
                end
              end
            end
            it_behaves_like(
              'a bootstrap page with an alert',
              'info',
              'Update successful'
            )
          end
          describe 'without checking anything' do
            before do
              visit '/box/in'
              click_button 'Mark'
              click_link 'mark-read'
            end
            it_behaves_like(
              'a bootstrap page with an alert',
              'warning',
              'Nothing to do'
            )
          end
          describe 'after checking a box' do
            describe 'Marking Read' do
              before do
                visit '/box/in'
                click_link 'Last'
                check "objects_conversations_#{unread_conversation.id}"
                click_button 'Mark'
                click_link 'mark-read'
              end
              it_behaves_like(
                'a bootstrap page with an alert',
                'info',
                'Update successful'
              )
            end
            describe 'Marking Ignored' do
              before do
                visit '/box/in'
                click_link 'Last'
                check "objects_conversations_#{unread_conversation.id}"
                click_button 'Mark'
                click_link 'mark-ignored'
              end
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

    describe 'Within a collective' do
      describe 'Showing' do
        describe 'at /collectives/groups:membered-group/box/in' do
          before do
            visit '/collectives/groups:membered-group/box/in'
          end
          it_behaves_like(
            'a bootstrap page listing a collection of items',
            MessageTrain::Conversation,
            plural_title: 'Inbox',
            minimum: 1
          )
        end
      end

      describe 'Marking', js: true do
        describe 'at /collectives/groups:membered-group/box/in' do
          describe 'without checking anything' do
            before do
              visit '/collectives/groups:membered-group/box/in'
              click_button 'Mark'
              click_link 'mark-read'
            end
            it_behaves_like(
              'a bootstrap page with an alert',
              'warning',
              'Nothing to do'
            )
          end
          describe 'after checking a box' do
            describe 'Marking Read' do
              before do
                visit '/collectives/groups:membered-group/box/in'
                check "objects_conversations_#{membered_group_conversation.id}"
                click_button 'Mark'
                click_link 'mark-read'
              end
              it_behaves_like(
                'a bootstrap page with an alert',
                'info',
                'Update successful'
              )
            end
            describe 'Marking Ignored' do
              before do
                visit '/collectives/groups:membered-group/box/in'
                check "objects_conversations_#{membered_group_conversation.id}"
                click_button 'Mark'
                click_link 'mark-ignored'
              end
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
  end

  describe 'When logged in as admin-user' do
    before do
      login_as admin_user
    end

    describe 'Showing' do
      describe 'at /box/in' do
        before do
          visit '/box/in'
        end

        describe 'lists Roles dropdown' do
          subject { page }
          it { should have_css('li.dropdown a.dropdown-toggle', text: 'Roles') }
        end
      end
    end
  end
  describe 'When logged in as superadmin-user' do
    before do
      login_as superadmin_user
    end

    describe 'Showing' do
      describe 'at /box/in' do
        before do
          visit '/box/in'
        end

        describe 'lists Roles dropdown' do
          subject { page }
          it { should have_css('li.dropdown a.dropdown-toggle', text: 'Roles') }
        end
      end
    end
  end
end
