require 'rails_helper'

describe NightTrain::BoxesController do
  include_context 'loaded site'
  include ControllerMacros
  routes { NightTrain::Engine.routes }

  let(:valid_params) { { 'conversations' => {unread_conversation.id.to_s => unread_conversation.id} } }
  let(:invalid_params) { { 'conversations' => {'999' => 999} } }
  
  before do
    login_user first_user
  end

  describe "GET #show" do
    before do
      get :show, division: 'in'
    end
    it_should_behave_like 'a successful page', which_renders: 'show'

    context 'loads box into @box' do
      subject { assigns(:box) }
      it { should be_a NightTrain::Box }
    end

    context 'loads conversations into @conversations' do
      subject { assigns(:conversations) }
      its(:first) { should be_a NightTrain::Conversation }
      it { should have_at_least(2).items }
    end
  end

  describe "PATCH/PUT #update" do
    describe 'with invalid params' do
      before do
        put :update, division: 'in', mark_to_set: 'read', objects: invalid_params
      end
      it_should_behave_like 'a page with an error message', "Conversation 999 not found in box"
    end
    describe 'without params' do
      before do
        put :update, division: 'in', mark_to_set: 'read'
      end
      it_should_behave_like 'a page with an alert message', 'Nothing to do'
    end
    describe 'with valid params' do
      before do
        put :update, division: 'in', mark_to_set: 'read', objects: valid_params
      end
      it_should_behave_like 'a page with a notice message', 'Update successful'
    end
  end

  describe "DELETE #destroy" do
    describe 'with invalid params' do
      before do
        delete :destroy, division: 'in', mark_to_set: 'ignore', objects: invalid_params
      end
      it_should_behave_like 'a page with an error message', "Conversation 999 not found in box"
    end
    describe 'without params' do
      before do
        delete :destroy, division: 'in'
      end
      it_should_behave_like 'a page with an alert message', 'Nothing to do'
    end
    describe 'with valid params' do
      context 'ignoring' do
        before do
          delete :destroy, division: 'in', mark_to_set: 'ignore', objects: valid_params
        end
        it_should_behave_like 'a page with a notice message', 'Update successful'
      end
      context 'unignoring' do
        before do
          delete :destroy, division: 'in', mark_to_set: 'unignore', objects: valid_params
        end
        it_should_behave_like 'a page with a notice message', 'Update successful'
      end
    end
  end
end