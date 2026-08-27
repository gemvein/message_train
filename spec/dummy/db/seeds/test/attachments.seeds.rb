after 'test:conversations' do
  FactoryBot.create(
    :attachment,
    attachment: Rack::Test::UploadedFile.new(
      'spec/dummy/app/assets/files/message_train/attachments/image-sample.jpg'
    )
  )
  FactoryBot.create(
    :attachment,
    attachment: Rack::Test::UploadedFile.new(
      'spec/dummy/app/assets/files/message_train/attachments/pdf-sample.pdf'
    )
  )
end
