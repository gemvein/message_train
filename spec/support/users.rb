shared_context 'users' do
  let(:first_user) { User.find_by_display_name('First User') }
  let(:second_user) { User.find_by_display_name('Second User') }
end