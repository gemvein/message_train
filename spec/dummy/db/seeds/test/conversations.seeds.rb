after :users, :groups do
  first_user = User.friendly.find('first-user')

  # Create some conversations that first user has received
  FactoryBot.create_list(
    :message_from_random_sender,
    10,
    recipients_to_save: { 'users' => first_user.slug }
  )

  # Create some conversations that first user has sent
  FactoryBot.create_list(:message, 10, sender: first_user)
end
