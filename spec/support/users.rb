shared_context 'users' do
  let(:first_user) { User.friendly.find('first-user') }
  let(:second_user) { User.friendly.find('second-user') }
  let(:third_user) { User.friendly.find('third-user') }
  let(:fourth_user) { User.friendly.find('fourth-user') }
  let(:fourth_user) { User.friendly.find('fourth-user') }
  let(:superadmin_user) { User.friendly.find('superadmin-user') }
  let(:admin_user) { User.friendly.find('admin-user') }
  let(:silent_user) { User.friendly.find('silent-user') }
  let(:last_user) { User.order('id').last }
end