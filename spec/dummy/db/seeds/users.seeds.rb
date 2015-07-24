first_user = FactoryGirl.create(
    :user,
    display_name: 'First User'
)
second_user = FactoryGirl.create(
    :user,
    display_name: 'Second User'
)
5.times do
  FactoryGirl.create(:user)
end

FactoryGirl.create(:message, subject: 'This should turn into a draft', sender: first_user, recipients: {})

User.find_each do |user|
  # Create some conversations that this user has received
  FactoryGirl.create_list(:message_from_random_sender, [*5..10].sample, recipients: { 'users' => user.slug })

  # Create some conversations that this user has sent
  FactoryGirl.create_list(:message, [*5..10].sample, sender: user)
end