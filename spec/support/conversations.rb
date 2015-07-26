shared_context 'conversations' do
  let(:sent_conversation) { NightTrain::Conversation.find_by_subject('Sent Conversation') }
  let(:unread_conversation) { NightTrain::Conversation.find_by_subject('Unread Conversation') }
  let(:ignored_conversation) { NightTrain::Conversation.find_by_subject('Ignored Conversation') }
  let(:trashed_conversation) { NightTrain::Conversation.find_by_subject('Trashed Conversation') }
  let(:read_conversation) { NightTrain::Conversation.find_by_subject('Read Conversation') }
  let(:deleted_conversation) { NightTrain::Conversation.find_by_subject('Deleted Conversation') }
end