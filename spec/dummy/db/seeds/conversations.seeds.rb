after :users, :groups do
  first_user = User.friendly.find('first-user')
  second_user = User.friendly.find('second-user')

  first_group = Group.find_by_slug('first-group')

  sent_message = FactoryGirl.create(
      :simple_message,
      sender: first_user,
      recipients_to_save: { 'users' => second_user.slug },
      subject: 'Sent Conversation'
  )

  unread_message = FactoryGirl.create(
      :simple_message,
      sender: second_user,
      recipients_to_save: { 'users' => first_user.slug },
      subject: 'Unread Conversation'
  )

  ignored_message = FactoryGirl.create(
      :simple_message,
      sender: second_user,
      recipients_to_save: { 'users' => first_user.slug },
      subject: 'Ignored Conversation'
  )
  ignored_message.conversation.set_ignored(first_user)

  trashed_message = FactoryGirl.create(
      :simple_message,
      sender: second_user,
      recipients_to_save: { 'users' => first_user.slug },
      subject: 'Trashed Conversation'
  )
  trashed_message.mark_trash_for(first_user)

  read_message = FactoryGirl.create(
      :simple_message,
      sender: second_user,
      recipients_to_save: { 'users' => first_user.slug },
      subject: 'Read Conversation'
  )
  read_message.mark_read_for(first_user)

  deleted_message = FactoryGirl.create(
      :simple_message,
      sender: second_user,
      recipients_to_save: { 'users' => first_user.slug },
      subject: 'Deleted Conversation'
  )
  deleted_message.mark_deleted_for(first_user)

  group_message = FactoryGirl.create(
      :simple_message,
      sender: first_user,
      recipients_to_save: { 'groups' => first_group.slug },
      subject: 'Group Message'
  )

  draft_message = FactoryGirl.create(
      :simple_message,
      subject: 'This should turn into a draft',
      sender: first_user,
      recipients_to_save: {}
  )

  User.find_each do |user|
    # Create some conversations that this user has received
    FactoryGirl.create_list(:message_from_random_sender, [*5..10].sample, recipients_to_save: { 'users' => user.slug })

    # Create some conversations that this user has sent
    FactoryGirl.create_list(:message, [*5..10].sample, sender: user)
  end
end