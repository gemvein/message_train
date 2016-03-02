after :users, :groups do
  User.find_each do |user|
    # Create some conversations that this user has received
    FactoryGirl.create_list(
      :message_from_random_sender,
      [*5..10].sample,
      recipients_to_save: { 'users' => user.slug }
    )

    # Create some conversations that this user has sent
    FactoryGirl.create_list(:message, [*5..10].sample, sender: user)
  end
end
