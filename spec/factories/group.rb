FactoryGirl.define do
  factory :group do
    title { Faker::Lorem.sentence }
    description { Faker::Lorem.paragraphs([*1..5].sample).join("\n\n") }
    transient do
      owner { User.order("RANDOM()").first }
      member_count 5
    end
    # the after(:create) yields two values; the user instance itself and the
    # evaluator, which stores all values from the factory, including transient
    # attributes; `create_list`'s second argument is the number of records
    # to create and we make sure the user is associated properly to the post
    after(:create) do |group, evaluator|
      evaluator.owner.add_role(:owner, group)
      User.where('id != ?', group.id).order("RANDOM()").limit(evaluator.member_count).find_each do |user|
        user.add_role(:member, group)
      end
    end
  end
end
