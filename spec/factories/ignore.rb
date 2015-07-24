FactoryGirl.define do
  factory :ignore, class: 'NightTrain::Ignore' do
    recipient {
       User
         .order('RANDOM()')
         .first
     }
    conversation {
      NightTrain::Conversation
          .order('RANDOM()')
          .first
    }
  end
end