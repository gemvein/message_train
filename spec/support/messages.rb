shared_context 'messages' do
  let(:sent_message) { sent_conversation.messages.first }
  let(:unread_message) { unread_conversation.messages.first }
  let(:to_many_message) { to_many_conversation.messages.first }
  let(:ignored_message) { ignored_conversation.messages.first }
  let(:trashed_message) { trashed_conversation.messages.first }
  let(:read_message) { read_conversation.messages.first }
  let(:deleted_message) { deleted_conversation.messages.first }
  let(:group_message) { group_conversation.messages.first }
  let(:membered_group_message) { membered_group_conversation.messages.first }
  let(:membered_group_trashed_message) { membered_group_trashed_conversation.messages.first }
  let(:membered_group_read_message) { membered_group_read_conversation.messages.first }
  let(:membered_group_ignored_message) { membered_group_ignored_conversation.messages.first }
  let(:membered_group_deleted_message) { membered_group_deleted_conversation.messages.first }
  let(:membered_group_draft_message) { membered_group_draft.messages.first }
  let(:owned_group_draft_message) { owned_group_draft.messages.first }
  let(:someone_elses_message) { someone_elses_conversation.messages.first }
  let(:draft_message) { draft_conversation.messages.first }
  let(:long_message) { long_conversation.messages.first }
end