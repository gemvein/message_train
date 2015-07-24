after :users, :groups do
  first_user = User.friendly.find('first-user')
  second_user = User.friendly.find('second-user')

  first_group = Group.find_by_slug('first-group')

  ignored_message = FactoryGirl.create(:message, sender: second_user, recipients: { 'users' => first_user.slug }, subject: 'Ignored Conversation')
  ignored_message.conversation.set_ignored_by(first_user)

  FactoryGirl.create(:message, sender: first_user, recipients: { 'groups' => first_group.slug })

  FactoryGirl.create(:message, subject: 'This should turn into a draft', sender: first_user, recipients: {})

  User.find_each do |user|
    # Create some conversations that this user has received
    FactoryGirl.create_list(:message_from_random_sender, [*5..10].sample, recipients: { 'users' => user.slug })

    # Create some conversations that this user has sent
    FactoryGirl.create_list(:message, [*5..10].sample, sender: user)
  end
end