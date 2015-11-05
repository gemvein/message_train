FactoryGirl.define do
  factory :message, class: 'MessageTrain::Message' do
    sender {
      User
         .order('RANDOM()')
         .first
    }
    recipients_to_save { { 'users' =>
       User
         .where('id != ?', sender.id)
         .order('RANDOM()')
         .limit([*1..5].sample)
         .collect { |x| x.slug }
         .join(', ')
    } }
    subject { Faker::Lorem.sentence }
    body { "<p>#{Faker::Lorem.paragraphs([*1..5].sample).join('</p><p>')}</p>" }

    transient do
      generate_attachment? { [*1..100].sample >= 80 }
      generate_response? { [*1..100].sample >= 50 }
      generate_ignore? { [*1..100].sample >= 80 }
    end

    # the after(:create) yields two values; the user instance itself and the
    # evaluator, which stores all values from the factory, including transient
    # attributes; `create_list`'s second argument is the number of records
    # to create and we make sure the user is associated properly to the post
    after(:create) do |message, evaluator|
      if evaluator.generate_attachment?
        FactoryGirl.create(:attachment, message: message)
      end
      if message.recipients_to_save['users'].present?
        participants = (message.recipients_to_save['users'].split(',') + [message.sender.slug]).collect{ |x| x.strip }
        if evaluator.generate_ignore?
          ignorer = User.friendly.find(participants.sample)
          participants = participants - [ignorer.slug]
          message.conversation.set_ignored(ignorer)
        end
        if evaluator.generate_response? && participants.count > 1
          response_sender = User.friendly.find(participants.sample)
          response_recipients = participants - [response_sender.slug]
          FactoryGirl.create(
            :message,
            sender: response_sender,
            recipients_to_save: { 'users' => response_recipients.join(', ') },
            conversation: message.conversation
          )
        end
      end
    end

    factory :message_from_random_sender do
      sender {
        recipient_user_ids = recipients_to_save['users'].split(',').collect{ |x| User.friendly.find(x.strip).id }
        User
          .where
          .not(id: recipient_user_ids )
          .order('RANDOM()')
          .first
      }
    end

    factory :simple_message do
      generate_ignore? false
      generate_response? false
      generate_attachment? false
    end
  end
end