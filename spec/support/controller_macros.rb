module ControllerMacros
  def access_anonymous
    sign_out :user
    User.new
  end

  def login_user(user)
    @request.env["devise.mapping"] = Devise.mappings[:user]
    sign_in user
    user
  end
end