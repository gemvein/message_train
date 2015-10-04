require 'rails_helper'

module MessageTrain
  RSpec.describe Attachment do
    include_context 'loaded site'

    describe 'Model' do
      it { should belong_to :message }
      it { should have_attached_file :attachment }
      it { should validate_attachment_presence :attachment }
      it { should validate_attachment_content_type(:attachment).allowing(
                                                       'application/pdf',
                                                       'application/vnd.ms-excel',
                                                       'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
                                                       'application/msword',
                                                       'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
                                                       'application/rtf',
                                                       'text/plain',
                                                       'image/bmp',
                                                       'image/gif',
                                                       'image/jpeg',
                                                       'image/pjpeg',
                                                       'image/png',
                                                       'image/x-png',
                                                       'application/bmp',
                                                       'application/gif',
                                                       'application/jpeg',
                                                       'application/pjpeg',
                                                       'application/png',
                                                       'application/x-png',
                                                       'x-application/bmp',
                                                       'x-application/gif',
                                                       'x-application/jpeg',
                                                       'x-application/pjpeg',
                                                       'x-application/png',
                                                       'x-application/x-png'
                                                  ).rejecting(
                                                       'image/tiff',
                                                       'image/svg'
                                                  ) }
    end
    describe 'Scopes and Methods' do
      describe '#image?' do
        context 'when it is an image' do
          let(:image_attachment) { FactoryGirl.create(:attachment,
                                                      message: unread_message,
                                                      attachment: File.open('spec/dummy/app/assets/files/message_train/attachments/1917-Boys_Race_Above-Wiki.jpg'
                                                      ) ) }
          subject { image_attachment.image? }
          it { should eq true }
        end
        context 'when it is not an image' do
          let(:image_attachment) { FactoryGirl.create(:attachment,
                                                      message: unread_message,
                                                      attachment: File.open('spec/dummy/app/assets/files/message_train/attachments/example.pdf'
                                                      ) ) }
          subject { image_attachment.image? }
          it { should eq false }
        end
      end
    end
  end
end
