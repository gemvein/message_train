after :users, :groups do
  first_user = User.friendly.find('first-user')
  second_user = User.friendly.find('second-user')
  third_user = User.friendly.find('third-user')
  fourth_user = User.friendly.find('fourth-user')
  superadmin_user = User.friendly.find('superadmin-user')

  first_group = Group.find_by_slug('first-group')
  membered_group = Group.find_by_slug('membered-group')

  FactoryGirl.create(
    :simple_message,
    sender: first_user,
    recipients_to_save: { 'users' => second_user.slug },
    subject: 'Sent Conversation'
  )

  FactoryGirl.create(
    :simple_message,
    sender: second_user,
    recipients_to_save: { 'users' => first_user.slug },
    subject: 'Unread Conversation'
  )

  FactoryGirl.create(
    :simple_message,
    sender: first_user,
    recipients_to_save: {
      'users' => [
        second_user.slug,
        third_user.slug,
        fourth_user.slug
      ].join(', ')
    },
    subject: 'To Many Conversation'
  )

  FactoryGirl.create(
    :simple_message,
    sender: second_user,
    recipients_to_save: { 'users' => first_user.slug },
    subject: 'Ignored Conversation'
  ).conversation.participant_ignore(first_user)

  FactoryGirl.create(
    :simple_message,
    sender: second_user,
    recipients_to_save: { 'users' => first_user.slug },
    subject: 'Trashed Conversation'
  ).mark_trash_for(first_user)

  FactoryGirl.create(
    :simple_message,
    sender: second_user,
    recipients_to_save: { 'users' => first_user.slug },
    subject: 'Read Conversation'
  ).mark_read_for(first_user)

  FactoryGirl.create(
    :simple_message,
    sender: second_user,
    recipients_to_save: { 'users' => first_user.slug },
    subject: 'Attachment Conversation',
    generate_attachment?: true
  )

  FactoryGirl.create(
    :simple_message,
    sender: second_user,
    recipients_to_save: { 'users' => first_user.slug },
    subject: 'Deleted Conversation'
  ).mark_deleted_for(first_user)

  FactoryGirl.create(
    :simple_message,
    sender: first_user,
    recipients_to_save: { 'groups' => first_group.slug },
    subject: 'Group Announcement'
  )

  FactoryGirl.create(
    :simple_message,
    sender: second_user,
    recipients_to_save: { 'groups' => membered_group.slug },
    subject: 'Membered Group Announcement'
  )

  FactoryGirl.create(
    :simple_message,
    sender: second_user,
    recipients_to_save: { 'groups' => membered_group.slug },
    subject: 'Membered Group Trashed Conversation'
  ).mark(:trash, first_user)

  FactoryGirl.create(
    :simple_message,
    sender: second_user,
    recipients_to_save: { 'groups' => membered_group.slug },
    subject: 'Membered Group Read Conversation'
  ).mark(:read, first_user)

  FactoryGirl.create(
    :simple_message,
    sender: second_user,
    recipients_to_save: { 'groups' => membered_group.slug },
    subject: 'Membered Group Ignored Conversation'
  ).conversation.participant_ignore(first_user)

  FactoryGirl.create(
    :simple_message,
    sender: second_user,
    recipients_to_save: { 'groups' => membered_group.slug },
    subject: 'Membered Group Deleted Conversation'
  ).mark(:deleted, first_user)

  FactoryGirl.create(
    :simple_message,
    sender: second_user,
    recipients_to_save: { 'groups' => membered_group.slug },
    subject: 'Membered Group Draft',
    draft: true
  )

  FactoryGirl.create(
    :simple_message,
    sender: first_user,
    recipients_to_save: { 'groups' => first_group.slug },
    subject: 'Owned Group Draft',
    draft: true
  )

  FactoryGirl.create(
    :simple_message,
    sender: superadmin_user,
    recipients_to_save: { 'roles' => 'admin' },
    subject: 'Role Conversation'
  )

  FactoryGirl.create(
    :simple_message,
    sender: superadmin_user,
    recipients_to_save: { 'roles' => 'admin' },
    subject: 'Role Draft',
    draft: true
  )

  FactoryGirl.create(
    :simple_message,
    subject: 'This should turn into a draft',
    sender: first_user,
    recipients_to_save: {}
  )

  FactoryGirl.create(
    :simple_message,
    subject: "Someone Else's Conversation",
    sender: User.order(:id).last,
    recipients_to_save: { 'users' => second_user.slug }
  )

  long_message = FactoryGirl.create(
    :simple_message,
    subject: 'Long Conversation',
    sender: second_user,
    recipients_to_save: { 'users' => first_user.slug }
  )

  FactoryGirl.create_list(
    :simple_message,
    11,
    conversation: long_message.conversation,
    sender: first_user,
    recipients_to_save: { 'users' => second_user.slug }
  )
end
