shared_context 'conversations' do
  let(:sent_conversation) { MessageTrain::Conversation.find_by_subject('Sent Conversation') }
  let(:unread_conversation) { MessageTrain::Conversation.find_by_subject('Unread Conversation') }
  let(:to_many_conversation) { MessageTrain::Conversation.find_by_subject('To Many Conversation') }
  let(:ignored_conversation) { MessageTrain::Conversation.find_by_subject('Ignored Conversation') }
  let(:trashed_conversation) { MessageTrain::Conversation.find_by_subject('Trashed Conversation') }
  let(:read_conversation) { MessageTrain::Conversation.find_by_subject('Read Conversation') }
  let(:deleted_conversation) { MessageTrain::Conversation.find_by_subject('Deleted Conversation') }
  let(:group_conversation) { MessageTrain::Conversation.find_by_subject('Group Announcement') }
  let(:membered_group_conversation) { MessageTrain::Conversation.find_by_subject('Membered Group Announcement') }
  let(:membered_group_trashed_conversation) { MessageTrain::Conversation.find_by_subject('Membered Group Trashed Conversation') }
  let(:membered_group_read_conversation) { MessageTrain::Conversation.find_by_subject('Membered Group Read Conversation') }
  let(:membered_group_ignored_conversation) { MessageTrain::Conversation.find_by_subject('Membered Group Ignored Conversation') }
  let(:membered_group_deleted_conversation) { MessageTrain::Conversation.find_by_subject('Membered Group Deleted Conversation') }
  let(:membered_group_draft) { MessageTrain::Conversation.find_by_subject('Membered Group Draft') }
  let(:owned_group_draft) { MessageTrain::Conversation.find_by_subject('Owned Group Draft') }
  let(:someone_elses_conversation) { MessageTrain::Conversation.find_by_subject("Someone Else's Conversation") }
  let(:draft_conversation) { MessageTrain::Conversation.find_by_subject('This should turn into a draft')}
  let(:long_conversation) { MessageTrain::Conversation.find_by_subject('Long Conversation')}
end