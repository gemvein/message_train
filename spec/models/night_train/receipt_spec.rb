require 'rails_helper'

module NightTrain
  RSpec.describe Receipt do
    describe 'Model' do
      # Relationships
      it { should belong_to :message }
      it { should belong_to :recipient }
      # Validations
      it { should validate_presence_of :message }
      it { should validate_presence_of :recipient }
    end
  end
end
