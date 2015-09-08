shared_context 'conversations' do
  let(:sent_conversation) { MessageTrain::Conversation.find_by_subject('Sent Conversation') }
  let(:unread_conversation) { MessageTrain::Conversation.find_by_subject('Unread Conversation') }
  let(:ignored_conversation) { MessageTrain::Conversation.find_by_subject('Ignored Conversation') }
  let(:trashed_conversation) { MessageTrain::Conversation.find_by_subject('Trashed Conversation') }
  let(:read_conversation) { MessageTrain::Conversation.find_by_subject('Read Conversation') }
  let(:deleted_conversation) { MessageTrain::Conversation.find_by_subject('Deleted Conversation') }
  let(:group_conversation) { MessageTrain::Conversation.find_by_subject('Group Announcement') }
  let(:membered_group_conversation) { MessageTrain::Conversation.find_by_subject('Membered Group Announcement') }
  let(:someone_elses_conversation) { MessageTrain::Conversation.find_by_subject("Someone Else's Conversation") }
  let(:draft_conversation) { MessageTrain::Conversation.find_by_subject('This should turn into a draft')}
end