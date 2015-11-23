shared_context 'loaded site' do
  include_context 'users'
  include_context 'groups'
  include_context 'roles'
  include_context 'conversations'
  include_context 'messages'
  include_context 'attachments'
end