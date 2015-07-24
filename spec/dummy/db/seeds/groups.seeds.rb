after :users do
  first_user = User.friendly.find('first-user')

  first_group = FactoryGirl.create(
    :group,
    title: 'First Group',
    owner: first_user
  )
end