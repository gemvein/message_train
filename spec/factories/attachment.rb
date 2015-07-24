FactoryGirl.define do
  factory :attachment, class: 'NightTrain::Attachment' do
    message { NightTrain::Message.order('RANDOM()').first }
    attachment { File.open(Dir['app/assets/files/night_train/attachments/*'].sample) }
  end
end