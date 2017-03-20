require 'rails_helper'

describe MessageTrain::BoxesController do
  include_context 'loaded site'
  include ControllerMacros
  routes { MessageTrain::Engine.routes }

  let(:valid_params) do
    {
      'conversations' => {
        unread_conversation.id.to_s => unread_conversation.id
      }
    }
  end
  let(:invalid_params) do
    { 'conversations' => { '999' => 999 } }
  end
  let(:disallowed_params) do
    {
      'conversations' => {
        someone_elses_conversation.id.to_s => someone_elses_conversation.id
      }
    }
  end

  before do
    login_user first_user
  end

  describe 'GET #show' do
    before do
      get :show, params: { division: 'in' }
    end
    it_should_behave_like 'a successful page', which_renders: 'show'

    context 'loads box into @box' do
      subject { assigns(:box) }
      it { should be_a MessageTrain::Box }
    end

    context 'loads conversations into @conversations' do
      subject { assigns(:conversations) }
      its(:first) { should be_a MessageTrain::Conversation }
      it { should have_at_least(2).items }
    end
  end

  describe 'PATCH/PUT #update' do
    describe 'with invalid params' do
      before do
        put(
          :update,
          params: {
            division: 'in',
            mark_to_set: 'read',
            objects: invalid_params
          }
        )
      end
      it_should_behave_like 'a 404 Not Found error'
    end
    describe 'with disallowed params' do
      before do
        put(
          :update,
          params: {
            division: 'in',
            mark_to_set: 'read',
            objects: disallowed_params
          }
        )
      end
      it_should_behave_like(
        'a page with an error message matching',
        /Access to Conversation \d+ denied/
      )
    end
    describe 'without params' do
      before do
        put :update, params: { division: 'in' }
      end
      it_should_behave_like 'a page with an alert message', 'Nothing to do'
    end
    describe 'with valid params' do
      before do
        put(
          :update,
          params: {
            division: 'in',
            mark_to_set: 'read',
            objects: valid_params
          }
        )
      end
      it_should_behave_like 'a page with a notice message', 'Update successful'
      it_should_behave_like 'a response without error'
    end
  end

  describe 'DELETE #destroy' do
    describe 'with invalid params' do
      before do
        delete(
          :destroy,
          params: {
            division: 'in',
            mark_to_set: 'ignore',
            objects: invalid_params
          }
        )
      end
      it_should_behave_like 'a 404 Not Found error'
    end
    describe 'without params' do
      before do
        delete :destroy, params: { division: 'in' }
      end
      it_should_behave_like 'a page with an alert message', 'Nothing to do'
    end
    describe 'with valid params' do
      context 'ignoring' do
        before do
          delete(
            :destroy,
            params: {
              division: 'in',
              mark_to_set: 'ignore',
              objects: valid_params
            }
          )
        end
        it_should_behave_like(
          'a page with a notice message',
          'Update successful'
        )
      end
      context 'unignoring' do
        before do
          delete(
            :destroy,
            params: {
              division: 'in',
              mark_to_set: 'unignore',
              objects: valid_params
            }
          )
        end
        it_should_behave_like(
          'a page with a notice message',
          'Update successful'
        )
      end
    end
  end
end
