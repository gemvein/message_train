require 'rails_helper'

module NightTrain
  RSpec.describe Ignore do
    describe 'Model' do
      it { should belong_to :conversation }
      it { should belong_to :recipient }
    end
    describe 'Scopes and Methods' do
      include_context 'loaded site'
      describe '#find_by_recipient' do
        subject { ignored_conversation.ignores.find_by_recipient(first_user) }
        it { should be_a NightTrain::Ignore }
      end
    end
  end
end
