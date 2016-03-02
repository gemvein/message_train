require 'rails_helper'
RSpec.feature 'Unsubscribes' do
  include_context 'loaded site'

  it_behaves_like 'an authenticated section', '/unsubscribes'

  describe 'When logged in' do
    before do
      login_as first_user
    end
    describe 'Index' do
      describe 'at /unsubscribes' do
        before do
          visit '/unsubscribes'
        end
        it_behaves_like(
          'a bootstrap page',
          title: 'Manage Your Email Notifications'
        )
        context 'displays a list of #subscriptions in .subscription' do
          subject { page }
          it { should have_css('#subscriptions .subscription', minimum: 3) }
        end
      end
    end
    describe 'Unsubscribing' do
      describe 'at /unsubscribes' do
        describe 'with a specific item' do
          before do
            visit '/unsubscribes'
            find("#unsubscribe-group-#{membered_group.id}").click
          end
          it_behaves_like(
            'a bootstrap page with an alert',
            'info',
            'You are now unsubscribed from Membered Group, which means that '\
              'you will not be notified by email of any messages received by '\
              'that Group.'
          )
        end
        describe 'with all button' do
          before do
            visit '/unsubscribes'
            click_link 'Disable All Notifications'
          end
          it_behaves_like(
            'a bootstrap page with an alert',
            'info',
            'You have unsubscribed from all messages, which means that you '\
              'will not be notified by email of any messages received in any '\
              'of your boxes.'
          )
        end
      end
    end
    describe 'Removing an Unsubscribe' do
      describe 'at /unsubscribes' do
        before do
          visit '/unsubscribes'
          find("#remove-unsubscribe-#{unsubscribed_group.id}").click
        end
        it_behaves_like(
          'a bootstrap page with an alert',
          'info',
          'You are no longer unsubscribed from Unsubscribed Group, which '\
            'means that you will now be notified by email of any messages '\
            'received in that Group.'
        )
      end
      describe 'with all button' do
        before do
          visit '/unsubscribes'
          click_link 'Disable All Notifications'
          click_link 'Enable Some Notifications'
        end
        it_behaves_like(
          'a bootstrap page with an alert',
          'info',
          'You are no longer unsubscribed from all messages, which means that '\
            'you will now be notified by email of any messages received in '\
            'boxes you are subscribed to.'
        )
      end
    end
  end
end
