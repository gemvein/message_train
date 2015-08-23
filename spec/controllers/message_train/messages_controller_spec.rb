require 'rails_helper'

describe MessageTrain::MessagesController do
  include_context 'loaded site'
  include ControllerMacros
  routes { MessageTrain::Engine.routes }

  # This should return the minimal set of attributes required to create a valid
  # Dog. As you add validations to Dog, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {
    { subject: 'Test Subject', recipients_to_save: {'users' => 'second-user, third-user'}, draft: false }
  }

  let(:draft_attributes) {
    { subject: 'Test Subject', recipients_to_save: {'users' => ''} }
  }

  let(:invalid_attributes) {
    { subject: nil }
  }

  let(:draft_message) { draft_conversation.messages.first }

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
      it { should be_a MessageTrain::Box }
    end

    context 'loads message into @message' do
      subject { assigns(:message) }
      it { should eq unread_conversation.messages.first }
    end
  end

  describe "GET #new" do
    before do
      get :new, box_division: 'in', conversation_id: unread_conversation.messages.first.conversation_id
    end
    it_should_behave_like 'a successful page', which_renders: 'new'

    context 'loads box into @box' do
      subject { assigns(:box) }
      it { should be_a MessageTrain::Box }
    end

    context 'loads message into @message' do
      subject { assigns(:message) }
      it { should be_a_new MessageTrain::Message }
      its(:subject) { should eq 'Re: Unread Conversation' }
    end
  end

  describe "GET #edit" do
    describe 'as someone other than the owner' do
      before do
        get :edit, box_division: 'in', id: someone_elses_conversation.messages.first.id
      end
      it_should_behave_like 'a 404 Not Found error'
    end
    describe 'as the owner' do
      describe 'when message is a not a draft' do
        before do
          get :edit, box_division: 'in', id: unread_conversation.messages.first.id
        end
        it_should_behave_like 'a 404 Not Found error'
      end
      describe 'when message is a draft' do
        before do
          get :edit, box_division: 'in', id: draft_message.id
        end
        it_should_behave_like 'a successful page', which_renders: 'edit'

        context 'loads requested message into @message' do
          subject { assigns(:message) }
          it { should eq draft_message }
        end
      end
    end
  end

  describe "POST #create" do
    describe 'with valid attributes' do
      describe 'when draft' do
        before do
          post :create, box_division: 'in', message: draft_attributes
        end
        it_should_behave_like 'a redirect to', '/box/drafts'
        it_should_behave_like 'a response without error'

        context "sets the flash with an alert of the messages's draft status" do
          subject { flash[:alert] }
          it { should eq 'Message saved as draft.'}
        end
      end
      describe 'when not draft' do
        before do
          post :create, box_division: 'in', message: valid_attributes
        end
        it_should_behave_like 'a redirect to', '/box/sent'
        it_should_behave_like 'a response without error'

        context "sets the flash with a notice of the messages's creation" do
          subject { flash[:notice] }
          it { should eq 'Message sent.'}
        end
      end
    end
    describe 'with valid attributes, counting' do
      it 'results in a new message' do
        expect { post :create, box_division: 'in', message: valid_attributes }.to change { MessageTrain::Message.count }.by(1)
      end
    end
    describe 'with invalid params' do
      before do
        post :create, box_division: 'in', message: invalid_attributes
      end
      it_should_behave_like 'a successful page', which_renders: 'new'

      context 'loads the given message into @message' do
        subject { assigns(:message) }
        it { should be_a_new(MessageTrain::Message).with(invalid_attributes) }
      end

      context "sets the flash with the message's errors" do
        subject { flash[:error] }
        it { should eq "Subject can't be blank"}
      end
    end

    describe 'with invalid params, counting' do
      it 'does not result in a new message' do
        expect { post :create, box_division: 'in', message: invalid_attributes }.to_not change { MessageTrain::Message.count }
      end
    end
  end

  describe "PUT #update" do
    describe 'as someone other than the owner' do
      before do
        put :update, box_division: 'in', id: someone_elses_conversation.messages.first.id, message: valid_attributes
      end
      it_should_behave_like 'a 404 Not Found error'
    end
    describe 'as the owner' do
      describe 'with invalid params' do
        before do
          put :update, box_division: 'in', id: draft_message.id, message: invalid_attributes
        end
        it_should_behave_like 'a successful page', which_renders: 'edit'
    
        context 'loads the given message into @message' do
          subject { assigns(:message) }
          it { should eq draft_message }
        end
    
        context 'does not update @message' do
          subject { draft_message.reload }
          its(:subject) { should eq 'This should turn into a draft' }
        end
    
        context "sets the flash with the message's errors" do
          subject { flash[:error] }
          it { should eq "Subject can't be blank"}
        end
      end
      describe 'with valid params' do
        describe 'when not a draft' do
          before do
            put :update, box_division: 'in', id: sent_conversation.messages.first.id, message: valid_attributes
          end
          it_should_behave_like 'a 404 Not Found error'
        end
        describe 'when a draft' do
          before do
            put :update, box_division: 'in', id: draft_message.id, message: valid_attributes
          end
          it_should_behave_like 'a redirect to', '/box/sent'
          it_should_behave_like 'a response without error'

          context 'updates @message' do
            subject { draft_message.reload }
            its(:subject) { should eq 'Test Subject' }
          end

          context "sets no alert" do
            subject { flash[:alert] }
            it { should be nil }
          end

          context "sets the flash with a notice of the message's update" do
            subject { flash[:notice] }
            it { should eq 'Message sent.'}
          end
        end
      end
      
    end
  end
end