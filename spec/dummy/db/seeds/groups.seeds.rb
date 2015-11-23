after :users do
  first_user = User.friendly.find('first-user')
  second_user = User.friendly.find('second-user')
  third_user = User.friendly.find('third-user')
  fourth_user = User.friendly.find('fourth-user')

  first_group = FactoryGirl.create(
    :group,
    title: 'First Group',
    owner: first_user
  )
  fourth_user.add_role(:member, first_group)

  membered_group = FactoryGirl.create(
      :group,
      title: 'Membered Group',
      owner: second_user
  )
  first_user.add_role(:member, membered_group)

  empty_group = FactoryGirl.create(
      :group,
      title: 'Empty Group',
      owner: first_user
  )
end