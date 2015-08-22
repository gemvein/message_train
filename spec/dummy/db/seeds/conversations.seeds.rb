after :users, :groups do
  first_user = User.friendly.find('first-user')
  second_user = User.friendly.find('second-user')
  third_user = User.friendly.find('third-user')

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

  someone_elses_message = FactoryGirl.create(
      :simple_message,
      subject: "Someone Else's Conversation",
      sender: User.order(:id).last,
      recipients_to_save: { 'users' => second_user.slug }
  )

  long_message = FactoryGirl.create(
      :simple_message,
      subject: "Long Conversation",
      sender: second_user,
      recipients_to_save: { 'users' => first_user.slug }
  )
  FactoryGirl.create_list(:simple_message, 11,
                          conversation: long_message.conversation,
                          sender: second_user,
                          recipients_to_save: { 'users' => first_user.slug }
  )
end