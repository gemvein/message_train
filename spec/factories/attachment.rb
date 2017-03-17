FactoryGirl.define do
  factory :attachment, class: 'MessageTrain::Attachment' do
    message { MessageTrain::Message.order('RANDOM()').first }
    attachment do
      File.open(
        Dir[
          Rails.root.join 'app/assets/files/message_train/attachments/*'
        ].sample
      )
    end
  end
end
