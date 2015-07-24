require 'rails_helper'

module NightTrain
  RSpec.describe Conversation do
    describe 'Model' do
      it { should have_many :messages }
      it { should have_many :ignores }
    end
    describe 'Scopes and Methods' do

    end
  end
end
