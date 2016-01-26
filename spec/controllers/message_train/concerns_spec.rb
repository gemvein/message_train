require 'rails_helper'

describe MessageTrain::BoxesController do
  include_context 'loaded site'
  include ControllerMacros
  routes { MessageTrain::Engine.routes }

  describe "GET #show"  do
    # describe 'when not logged in' do
    #   before do
    #     access_anonymous
    #     get :show, division: 'in'
    #   end
    #   it_should_behave_like 'a redirect with error', '/users/sign_in', 'You must sign in or sign up to continue.'
    # end

    describe 'when neither sending nor receiving is allowed' do
      before do
        login_user third_user
        get :show, division: 'in', collective_id: 'groups:first-group'
      end
      it_should_behave_like 'a redirect with error', '/', 'Access to that box denied'
    end

    describe 'when only sending is allowed' do
      before do
        login_user first_user
        get :show, division: 'in', collective_id: 'groups:first-group'
      end
      it_should_behave_like 'a redirect with error', '/collectives/groups:first-group/box/sent', 'Access to that box denied'
    end

    describe 'when only receiving is allowed' do
      before do
        login_user first_user
        get :show, division: 'sent', collective_id: 'groups:membered-group'
      end
      it_should_behave_like 'a redirect with error', '/collectives/groups:membered-group/box/in', 'Access to that box denied'
    end
  end
end