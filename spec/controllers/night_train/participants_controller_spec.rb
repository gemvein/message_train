require 'rails_helper'

describe NightTrain::ParticipantsController do
  include_context 'loaded site'
  include ControllerMacros
  routes { NightTrain::Engine.routes }

  before do
    login_user first_user
  end

  describe "GET #index" do
    before do
      get :index, box_division: 'in', format: :json
    end
    it_should_behave_like 'a successful page', which_renders: 'index'

    context 'loads participants into @participants' do
      subject { assigns(:participants) }
      its(:first) { should be_a User }
    end
  end

  describe "GET #show" do
    before do
      get :show, box_division: 'in', id: first_user.id, format: :json
    end
    it_should_behave_like 'a successful page', which_renders: 'show'

    context 'loads participant into @participant' do
      subject { assigns(:participant) }
      it { should eq first_user }
    end
  end
end