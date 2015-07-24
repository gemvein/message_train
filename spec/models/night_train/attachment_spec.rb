require 'rails_helper'

module NightTrain
  RSpec.describe Attachment do
    describe 'Model' do
      it { should belong_to :message }
    end
    describe 'Scopes and Methods' do

    end
  end
end
