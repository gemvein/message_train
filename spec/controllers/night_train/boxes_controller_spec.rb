require 'rails_helper'

describe NightTrain::BoxesController do
  include_context 'loaded site'
  include ControllerMacros
  routes { NightTrain::Engine.routes }

  let(:valid_params) { { read: [unread_conversation.id], trash: [read_conversation.id] } }
  let(:invalid_params) { { read: [999999] } }

  describe "GET #show" do
    before do
      login_user first_user
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
        login_user first_user
        put :update, division: 'in', mark: invalid_params
      end
      it_should_behave_like 'a page with an error message', "Conversation 999999 not found in box"
    end
    describe 'with valid params' do
      before do
        login_user first_user
        put :update, division: 'in', mark: valid_params
      end
      it_should_behave_like 'a page with a notice message', 'Update successful'
    end
  end

  describe "DELETE #destroy" do
    describe 'with invalid params' do
      before do
        login_user first_user
        delete :destroy, division: 'in', ignore: [999999]
      end
      it_should_behave_like 'a page with an error message', "Conversation 999999 not found in box"
    end
    describe 'with valid params' do
      context 'ignoring' do
        before do
          login_user first_user
          delete :destroy, division: 'in', ignore: [deleted_conversation.id]
        end
        it_should_behave_like 'a page with a notice message', 'Update successful'
      end
      context 'unignoring' do
        before do
          login_user first_user
          delete :destroy, division: 'in', unignore: [ignored_conversation.id]
        end
        it_should_behave_like 'a page with a notice message', 'Update successful'
      end
    end
  end
end