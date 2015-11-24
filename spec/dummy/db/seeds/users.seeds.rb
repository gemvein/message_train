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
fourth_user = FactoryGirl.create(
    :user,
    display_name: 'Fourth User',
    email: 'fourth.user@example.com'
)
unsubscribed_user = FactoryGirl.create(
    :user,
    display_name: 'Unsubscribed User',
    email: 'unsubscribed.user@example.com'
)
silent_user = FactoryGirl.create(
    :user,
    display_name: 'Silent User',
    email: 'silent.user@example.com'
)
superadmin_user = FactoryGirl.create(
    :user,
    display_name: 'Superadmin User',
    email: 'superadmin.user@example.com'
)
superadmin_user.add_role(:superadmin)
admin_user = FactoryGirl.create(
    :user,
    display_name: 'Admin User',
    email: 'admin.user@example.com'
)
admin_user.add_role(:admin)