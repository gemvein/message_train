FactoryGirl.define do
  factory :message, class: 'MessageTrain::Message' do
    sender do
      User
        .order('RANDOM()')
        .first
    end
    recipients_to_save do
      {
        'users' => User.where
                       .not(id: sender.id)
                       .where
                       .not(slug: 'silent-user')
                       .order('RANDOM()')
                       .limit([*1..5].sample)
                       .collect(&:slug)
                       .join(', ')
      }
    end
    subject { Faker::Lorem.sentence }
    body { "<p>#{Faker::Lorem.paragraphs([*1..5].sample).join('</p><p>')}</p>" }

    transient do
      generate_attachment? { [*1..100].sample >= 80 }
      generate_response? { [*1..100].sample >= 50 }
      generate_ignore? { [*1..100].sample >= 80 }
    end

    # the after(:create) yields two values; the message instance itself and the
    # evaluator, which stores all values from the factory, including transient
    # attributes
    after(:create) do |message, evaluator|
      if evaluator.generate_attachment?
        FactoryGirl.create(:attachment, message: message)
      end
      if message.recipients_to_save['users'].present?
        participants = (
          message.recipients_to_save['users'].split(',') + [message.sender.slug]
        ).collect(&:strip)
        if evaluator.generate_ignore?
          ignorer = User.friendly.find(participants.sample)
          participants -= [ignorer.slug]
          message.conversation.participant_ignore(ignorer)
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
      sender do
        recipient_user_ids = (
          recipients_to_save['users'].split(',')
            .collect { |x| User.friendly.find(x.strip).id }
        )
        User
          .where
          .not(id: recipient_user_ids)
          .where
          .not(slug: 'silent-user')
          .order('RANDOM()')
          .first
      end
    end

    factory :simple_message do
      generate_ignore? false
      generate_response? false
      generate_attachment? false
    end
  end
end
