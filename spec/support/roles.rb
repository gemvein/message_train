shared_context 'roles' do
  let(:superadmin_role) { Role.find_by_name('superadmin') }
  let(:admin_role) { Role.find_by_name('admin') }
end