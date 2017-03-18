# This block needs to be as long as it is.
shared_context 'conversations' do
  let(:sent_conversation) do
    MessageTrain::Conversation.find_by_subject('Sent Conversation')
  end
  let(:unread_conversation) do
    MessageTrain::Conversation.find_by_subject('Unread Conversation')
  end
  let(:to_many_conversation) do
    MessageTrain::Conversation.find_by_subject('To Many Conversation')
  end
  let(:ignored_conversation) do
    MessageTrain::Conversation.find_by_subject('Ignored Conversation')
  end
  let(:trashed_conversation) do
    MessageTrain::Conversation.find_by_subject('Trashed Conversation')
  end
  let(:read_conversation) do
    MessageTrain::Conversation.find_by_subject('Read Conversation')
  end
  let(:attachment_conversation) do
    MessageTrain::Conversation.find_by_subject('Attachment Conversation')
  end
  let(:deleted_conversation) do
    MessageTrain::Conversation.find_by_subject('Deleted Conversation')
  end
  let(:group_conversation) do
    MessageTrain::Conversation.find_by_subject('Group Announcement')
  end
  let(:membered_group_conversation) do
    MessageTrain::Conversation.find_by_subject('Membered Group Announcement')
  end
  let(:membered_group_trashed_conversation) do
    MessageTrain::Conversation.find_by_subject(
      'Membered Group Trashed Conversation'
    )
  end
  let(:membered_group_read_conversation) do
    MessageTrain::Conversation.find_by_subject(
      'Membered Group Read Conversation'
    )
  end
  let(:membered_group_ignored_conversation) do
    MessageTrain::Conversation.find_by_subject(
      'Membered Group Ignored Conversation'
    )
  end
  let(:membered_group_deleted_conversation) do
    MessageTrain::Conversation.find_by_subject(
      'Membered Group Deleted Conversation'
    )
  end
  let(:membered_group_draft) do
    MessageTrain::Conversation.find_by_subject('Membered Group Draft')
  end
  let(:owned_group_draft) do
    MessageTrain::Conversation.find_by_subject('Owned Group Draft')
  end
  let(:someone_elses_conversation) do
    MessageTrain::Conversation.find_by_subject("Someone Else's Conversation")
  end
  let(:draft_conversation) do
    MessageTrain::Conversation.find_by_subject('This should turn into a draft')
  end
  let(:long_conversation) do
    MessageTrain::Conversation.find_by_subject('Long Conversation')
  end
  let(:role_conversation) do
    MessageTrain::Conversation.find_by_subject('Role Conversation')
  end
  let(:role_draft) do
    MessageTrain::Conversation.find_by_subject('Role Draft')
  end
end
# rubocop:enable Metrics/BlockLength
