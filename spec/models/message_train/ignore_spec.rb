require 'rails_helper'

module MessageTrain
  RSpec.describe Ignore do
    describe 'Model' do
      it { should belong_to :conversation }
      it { should belong_to :participant }
      it { should validate_presence_of :conversation }
      it { should validate_presence_of :participant }
    end
    describe 'Scopes and Methods' do
      include_context 'loaded site'
      describe '.find_all_by_participant' do
        subject { ignored_conversation.ignores.find_all_by_participant(first_user) }
        its(:first) { should be_a MessageTrain::Ignore }
      end
      describe '.conversations' do
        subject { MessageTrain::Ignore.conversations }
        it { should include ignored_conversation }
      end
    end
  end
end
