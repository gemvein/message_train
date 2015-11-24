require 'rails_helper'
RSpec.feature 'Unsubscribes' do
  include_context 'loaded site'

  before do
    login_as first_user
  end
  describe 'Index' do
    describe 'at /unsubscribes' do
      before do
        visit '/unsubscribes'
      end
      it_behaves_like 'a bootstrap page', title: 'Manage Your Email Notifications'
      context "displays a list of #subscriptions in .subscription" do
        subject { page }
        it { should have_css("#subscriptions .subscription", minimum: 3) }
      end
    end
  end
  describe 'Unsubscribing' do
    describe 'at /unsubscribes' do
      before do
        visit '/unsubscribes'
        find("#unsubscribe-group-#{membered_group.id.to_s}").click
      end
      it_behaves_like 'a bootstrap page with an alert', 'info', 'You are now unsubscribed from Membered Group, which means that you will not be notified by email of any messages received by that Group.'
    end
  end
  describe 'Removing an Unsubscribe' do
    describe 'at /unsubscribes' do
      before do
        visit '/unsubscribes'
        find("#remove-unsubscribe-#{unsubscribed_group.id.to_s}").click
      end
      it_behaves_like 'a bootstrap page with an alert', 'info', 'You are no longer unsubscribed from Unsubscribed Group, which means that you will now be notified by email of any messages received in that Group.'
    end
  end
end
