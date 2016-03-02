FactoryGirl.create(
  :user,
  display_name: 'First User',
  email: 'first.user@example.com'
)

FactoryGirl.create(
  :user,
  display_name: 'Second User',
  email: 'second.user@example.com'
)

FactoryGirl.create(
  :user,
  display_name: 'Third User',
  email: 'third.user@example.com'
)

FactoryGirl.create(
  :user,
  display_name: 'Fourth User',
  email: 'fourth.user@example.com'
)

FactoryGirl.create(
  :user,
  display_name: 'Unsubscribed User',
  email: 'unsubscribed.user@example.com'
)

FactoryGirl.create(
  :user,
  display_name: 'Silent User',
  email: 'silent.user@example.com'
)

FactoryGirl.create(
  :user,
  display_name: 'Superadmin User',
  email: 'superadmin.user@example.com'
).add_role(:superadmin)

FactoryGirl.create(
  :user,
  display_name: 'Admin User',
  email: 'admin.user@example.com'
).add_role(:admin)
