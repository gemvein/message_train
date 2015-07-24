FactoryGirl.define do
  factory :message, class: 'NightTrain::Message' do
    sender {
      User
         .order('RANDOM()')
         .first
    }
    recipients { { 'users' =>
       User
         .where('id != ?', sender.id)
         .order('RANDOM()')
         .limit([*1..5].sample)
         .collect { |x| x.slug }
         .join(', ')
    } }
    subject { Faker::Lorem.sentence }
    body { Faker::Lorem.paragraphs([*1..5].sample).join("\n\n") }
    transient do
      attachment_count { [*0,0,0,0,1].sample }
      generate_response? { [true,false].sample }
      generate_ignore? { [*1..100].sample >= 80 }
    end

    # the after(:create) yields two values; the user instance itself and the
    # evaluator, which stores all values from the factory, including transient
    # attributes; `create_list`'s second argument is the number of records
    # to create and we make sure the user is associated properly to the post
    after(:create) do |message, evaluator|
      FactoryGirl.create_list(:attachment, evaluator.attachment_count, message: message)
      if message.recipients['users'].present?
        participants = (message.recipients['users'].split(',') + [message.sender.slug]).collect{ |x| x.strip }
        if evaluator.generate_ignore?
          ignorer = User.friendly.find(participants.sample)
          participants = participants - [ignorer.slug]
          message.conversation.set_ignored_by(ignorer)
        end
        if evaluator.generate_response? && participants.count > 1
          response_sender = User.friendly.find(participants.sample)
          response_recipients = participants - [response_sender.slug]
          FactoryGirl.create(
            :message,
            sender: response_sender,
            recipients: { 'users' => response_recipients.join(', ') },
            conversation: message.conversation
          )
        end
      end
    end

    factory :message_from_random_sender do
      sender {
        recipient_user_ids = recipients['users'].split(',').collect{ |x| User.friendly.find(x.strip).id }
        User
          .where('NOT (id IN (?))', recipient_user_ids )
          .order('RANDOM()')
          .first
      }
    end
  end
end