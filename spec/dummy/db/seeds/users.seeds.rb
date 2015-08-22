first_user = FactoryGirl.create(
    :user,
    display_name: 'First User',
    email: 'first.user@example.com'
)
second_user = FactoryGirl.create(
    :user,
    display_name: 'Second User',
    email: 'second.user@example.com'
)
third_user = FactoryGirl.create(
    :user,
    display_name: 'Third User',
    email: 'third.user@example.com'
)
