require 'rails_helper'

module NightTrain
  RSpec.describe Ignore do
    describe 'Model' do
      it { should belong_to :conversation }
      it { should belong_to :recipient }
    end
  end
end
