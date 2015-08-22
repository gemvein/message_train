shared_context 'users' do
  let(:first_user) { User.friendly.find('first-user') }
  let(:second_user) { User.friendly.find('second-user') }
  let(:third_user) { User.friendly.find('third-user') }
  let(:last_user) { User.order('id').last }
end