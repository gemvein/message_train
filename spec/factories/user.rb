FactoryGirl.define do
  factory :user do
    display_name { Faker::Name.name }
    email { "#{display_name.gsub(' ', '.').downcase}.#{rand(1000).to_s}@example.com" }
    password "password"
    password_confirmation "password"
  end
end