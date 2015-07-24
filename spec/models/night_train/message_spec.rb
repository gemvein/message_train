require 'rails_helper'

module NightTrain
  RSpec.describe Message do
    describe 'Model' do
      # Relationships
      it { should belong_to :conversation }
      it { should belong_to :sender }
      it { should have_many :attachments }
      it { should have_many :receipts }

      # Validations
      it { should validate_presence_of :sender }
      it { should validate_presence_of :subject }
    end
    describe 'Callbacks' do
      context 'sets draft to true on a message to no one' do
        subject { NightTrain::Message.find_by_subject('This should turn into a draft') }
        its(:receipts) { should be_empty }
        its(:recipients) { should be_empty }
        its(:draft) { should be true }
      end
    end
    describe 'Scopes and Methods' do

    end
  end
end
