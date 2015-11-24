require 'rails_helper'

describe MessageTrain::UnsubscribesController do
  include_context 'loaded site'
  include ControllerMacros
  routes { MessageTrain::Engine.routes }

  let(:valid_attributes) {
    { from_type: 'Group', from_id: membered_group.id }
  }

  let(:invalid_attributes) {
    { from_type: 'Group', from_id: empty_group.id }
  }

  before do
    login_user first_user
  end

  describe "GET #index" do
    before do
      get :index
    end
    it_should_behave_like 'a successful page', which_renders: 'index'

    context 'loads subscriptions into @subscriptions' do
      subject { assigns(:subscriptions) }
      it { should be_an Array }
      it { should have_at_least(3).items }
    end
  end

  describe "POST #create" do
    describe 'with invalid attributes' do
      before do
        post :create, unsubscribe: invalid_attributes
      end
      it_should_behave_like 'a 404 Not Found error'
    end
    describe 'with valid attributes' do
      before do
        post :create, unsubscribe: valid_attributes
      end
      it_should_behave_like 'a redirect with a message', '/unsubscribes', notice: 'You are now unsubscribed from Membered Group, which means that you will not be notified by email of any messages received by that Group.'
      it_should_behave_like 'a response without error'
    end
  end

  describe "DELETE #destroy" do
    before do
      delete :destroy, id: first_user.unsubscribes.where(from_type: 'Group', from_id: unsubscribed_group.id).first.id
    end
    it_should_behave_like 'a redirect with a message', '/unsubscribes', notice: 'You are no longer unsubscribed from Unsubscribed Group, which means that you will now be notified by email of any messages received in that Group.'
  end

end