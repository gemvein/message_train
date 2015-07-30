require 'rails_helper'
RSpec.feature 'Boxes' do
  include_context 'loaded site'

  describe 'Showing' do
    describe 'at /box/in' do
      describe 'when logged in' do
        before do
          login_as first_user
          visit '/box/in'
        end
        it_behaves_like 'a bootstrap page listing a collection of items', NightTrain::Conversation, plural_title: "Inbox", minimum: 2
      end
    end
  end
end
