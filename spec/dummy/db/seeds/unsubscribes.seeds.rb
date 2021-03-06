after :groups do
  first_user = User.friendly.find('first-user')
  unsubscribed_user = User.friendly.find('unsubscribed-user')
  first_group = Group.find_by_title('First Group')
  membered_group = Group.find_by_title('Membered Group')
  unsubscribed_group = Group.find_by_title('Unsubscribed Group')

  unsubscribed_user.unsubscribe_from(first_group)
  unsubscribed_user.unsubscribe_from(membered_group)
  unsubscribed_user.unsubscribe_from(unsubscribed_user)
  first_user.unsubscribe_from(unsubscribed_group)
end
