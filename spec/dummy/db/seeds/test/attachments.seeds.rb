after 'test:conversations' do
  FactoryGirl.create(
    :attachment,
    attachment: File.open(
      'spec/dummy/app/assets/files/message_train/attachments/image-sample.jpg'
    )
  )
  FactoryGirl.create(
    :attachment,
    attachment: File.open(
      'spec/dummy/app/assets/files/message_train/attachments/pdf-sample.pdf'
    )
  )
end
