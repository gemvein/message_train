shared_context 'groups' do
  let(:first_group) { Group.find_by_title('First Group') }
  let(:membered_group) { Group.find_by_title('Membered Group') }
end