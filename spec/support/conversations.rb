shared_context 'conversations' do
  let(:ignored_conversation) { NightTrain::Conversation.find_by_subject('Ignored Conversation') }
end