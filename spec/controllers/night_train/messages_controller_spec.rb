require 'rails_helper'

describe NightTrain::MessagesController do
  include_context 'loaded site'
  include ControllerMacros
  routes { NightTrain::Engine.routes }

  before do
    login_user first_user
  end

  describe "GET #show" do
    before do
      get :show, box_division: 'in', id: unread_conversation.messages.first.id, format: :json
    end
    it_should_behave_like 'a successful page', which_renders: 'show'

    context 'loads box into @box' do
      subject { assigns(:box) }
      it { should be_a NightTrain::Box }
    end

    context 'loads message into @message' do
      subject { assigns(:message) }
      it { should eq unread_conversation.messages.first }
    end
  end
end