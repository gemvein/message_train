require 'rails_helper'

module NightTrain
  RSpec.describe Conversation do
    describe 'Model' do
      it { should have_many :messages }
      it { should have_many :ignores }
    end
    describe 'Scopes and Methods' do
      include_context 'loaded site'
      describe '#set_ignored_by and #is_ignored_by?' do
        subject { ignored_conversation.is_ignored_by?(first_user) }
        it { should be true }
      end
    end
  end
end
