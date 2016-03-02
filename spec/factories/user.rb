FactoryGirl.define do
  factory :user do
    display_name { Faker::Name.name }
    sequence :email do |n|
      "#{display_name.tr(' ', '.').downcase}#{n}@example.com"
    end
    password 'password'
    password_confirmation 'password'
  end
end
