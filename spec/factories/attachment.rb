FactoryBot.define do
  factory :attachment, class: 'MessageTrain::Attachment' do
    message { MessageTrain::Message.order('RANDOM()').first }
    attachment do
      path = Dir[
        Rails.root.join 'app/assets/files/message_train/attachments/*'
      ].sample
      Rack::Test::UploadedFile.new(path)
    end
  end
end
