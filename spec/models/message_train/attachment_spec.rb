require 'rails_helper'

module MessageTrain
  RSpec.describe Attachment do
    include_context 'loaded site'

    describe 'Model' do
      it { is_expected.to belong_to :message }

      it 'has an attached file' do
        expect(image_attachment.attachment).to be_attached
      end

      it 'is invalid without an attached file' do
        attachment = build(:attachment, message: build(:message), attachment: nil)
        expect(attachment).not_to be_valid
        expect(attachment.errors[:attachment]).to be_present
      end

      it 'is valid for an allowed content type' do
        expect(image_attachment).to be_valid
      end

      it 'is invalid for a disallowed content type' do
        attachment = build(:attachment, message: build(:message))
        attachment.attachment.attach(
          io: StringIO.new('bogus'),
          filename: 'bogus.svg',
          content_type: 'image/svg'
        )
        expect(attachment).not_to be_valid
        expect(attachment.errors[:attachment]).to be_present
      end
    end
    describe 'Scopes and Methods' do
      describe '#image?' do
        context 'when it is an image' do
          subject { image_attachment.image? }
          it { is_expected.to eq true }
        end
        context 'when it is not an image' do
          subject { pdf_attachment.image? }
          it { is_expected.to eq false }
        end
      end
    end
  end
end
