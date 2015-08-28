after :users do
  first_user = User.friendly.find('first-user')
  second_user = User.friendly.find('second-user')

  first_group = FactoryGirl.create(
    :group,
    title: 'First Group',
    owner: first_user
  )

  membered_group = FactoryGirl.create(
      :group,
      title: 'Membered Group',
      owner: second_user
  )
  first_user.add_role(:member, membered_group)
end