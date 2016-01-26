MessageTrain.configure do |config|
  # config.slug_columns[:users] = :slug
  # config.name_columns[:users] = :name
  # config.user_model = 'User'
  # config.current_user_method = :current_user
  # config.user_sign_in_path = '/user/sign_in'
  # config.user_route_authentication_method = :user
  # config.address_book_methods[:users] = :address_book
  config.from_email = 'from@example.com'
  config.site_name = 'Example Site Name'
end

Rails.application.config.eager_load = true #FIXME: This is a weird place to put this. What would be better?