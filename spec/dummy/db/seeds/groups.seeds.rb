after :users do
  first_user = User.friendly.find('first-user')

  first_group = FactoryGirl.create(
    :group,
    title: 'First Group',
    owner: first_user
  )

  # Create some conversations that this user has received
  FactoryGirl.create(:message, sender: first_user, recipients: { 'groups' => first_group.slug })
end