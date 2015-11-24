require 'rails_helper'

module MessageTrain
  RSpec.describe Unsubscribe do
    include_context 'loaded site'

    describe 'Model' do
      # Relationships
      it { should belong_to :recipient }
      it { should belong_to :from }
      # Validations
      it { should validate_presence_of :recipient }
      it { should validate_presence_of :from }
    end
  end
end
