require 'rails_helper'

describe MessageTrain::BoxesController do
  include_context 'loaded site'
  include ControllerMacros
  routes { MessageTrain::Engine.routes }

  describe 'GET #show' do
    describe 'when neither sending nor receiving is allowed' do
      before do
        login_user third_user
        get(
          :show,
          params: {
            division: 'in',
            collective_id: 'groups:first-group'
          }
        )
      end
      it_should_behave_like(
        'a redirect with error',
        '/',
        'Access to that box denied'
      )
    end

    describe 'when only sending is allowed' do
      before do
        login_user first_user
        get(
          :show,
          params: {
            division: 'in',
            collective_id: 'groups:first-group'
          }
        )
      end
      it_should_behave_like(
        'a redirect with error',
        '/collectives/groups:first-group/box/sent',
        'Access to that box denied'
      )
    end

    describe 'when only receiving is allowed' do
      before do
        login_user first_user
        get(
          :show,
          params: {
            division: 'sent',
            collective_id: 'groups:membered-group'
          }
        )
      end
      it_should_behave_like(
        'a redirect with error',
        '/collectives/groups:membered-group/box/in',
        'Access to that box denied'
      )
    end
  end
end
