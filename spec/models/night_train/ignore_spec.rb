require 'rails_helper'

module NightTrain
  RSpec.describe Ignore do
    describe 'Model' do
      it { should belong_to :conversation }
      it { should belong_to :participant }
    end
    describe 'Scopes and Methods' do
      include_context 'loaded site'
      describe '.find_all_by_participant' do
        subject { ignored_conversation.ignores.find_all_by_participant(first_user) }
        its(:first) { should be_a NightTrain::Ignore }
      end
    end
  end
end
