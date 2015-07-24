first_user = FactoryGirl.create(
    :user,
    display_name: 'First User'
)
second_user = FactoryGirl.create(
    :user,
    display_name: 'Second User'
)
5.times do
  FactoryGirl.create(:user)
end
