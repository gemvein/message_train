require 'rails_helper'

module MessageTrain
  RSpec.describe Ignore do
    let(:user_in_box) { first_user.box(:in) }
    describe 'Model' do
      it { should belong_to :conversation }
      it { should belong_to :participant }
      it { should validate_presence_of :conversation }
      it { should validate_presence_of :participant }
    end
    describe 'Scopes and Methods' do
      include_context 'loaded site'
      describe '.find_all_by_participant' do
        subject do
          ignored_conversation.ignores.find_all_by_participant(first_user)
        end
        its(:first) { should be_a MessageTrain::Ignore }
      end
      describe '.conversations' do
        subject { MessageTrain::Ignore.conversations }
        it { should include ignored_conversation }
      end
      describe '.ignore' do
        context 'when not present' do
          it 'raises an ActiveRecord::RecordNotFound error' do
            expect { MessageTrain::Ignore.ignore(99_999_999, last_user.box) }
              .to raise_error(
                ActiveRecord::RecordNotFound,
                /Couldn't find MessageTrain::Conversation with 'id'=99999999/
              )
          end
        end
        context 'when bad type' do
          before do
            MessageTrain::Ignore.ignore(first_user, last_user.box)
          end
          subject { last_user.box.errors.all.first[:message] }
          it { should match(/Cannot ignore User/) }
        end
        context 'when not authorized' do
          before do
            MessageTrain::Ignore.ignore(read_conversation, last_user.box)
          end
          subject { last_user.box.errors.all.first[:message] }
          it { should match(/Access to Conversation ([0-9]+) denied/) }
        end
        context 'when authorized' do
          before do
            MessageTrain::Ignore.ignore(read_conversation, user_in_box)
          end
          subject { read_conversation.participant_ignored?(first_user) }
          it { should be true }
        end
      end
      describe '.unignore' do
        context 'when not present' do
          it 'raises an ActiveRecord::RecordNotFound error' do
            expect { MessageTrain::Ignore.unignore(99_999_999, last_user.box) }
              .to raise_error(
                ActiveRecord::RecordNotFound,
                /Couldn't find MessageTrain::Conversation with 'id'=99999999/
              )
          end
        end
        context 'when bad type' do
          before do
            MessageTrain::Ignore.unignore(first_user, last_user.box)
          end
          subject { last_user.box.errors.all.first[:message] }
          it { should match(/Cannot unignore User/) }
        end
        context 'when not authorized' do
          before do
            MessageTrain::Ignore.unignore(read_conversation, last_user.box)
          end
          subject { last_user.box.errors.all.first[:message] }
          it { should match(/Access to Conversation ([0-9]+) denied/) }
        end
        context 'when authorized' do
          before do
            MessageTrain::Ignore.unignore(ignored_conversation, user_in_box)
          end
          subject { ignored_conversation.participant_ignored?(first_user) }
          it { should be false }
        end
      end
    end
  end
end
