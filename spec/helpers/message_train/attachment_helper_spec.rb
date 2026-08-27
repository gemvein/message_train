require 'rails_helper'

describe MessageTrain::AttachmentsHelper do
  include_context 'loaded site'

  before do
    view.extend MessageTrain::ApplicationHelper
  end

  describe '#attachment_icon' do
    context 'when attachment is an image' do
      subject { helper.attachment_icon(image_attachment) }
      it { is_expected.to have_tag(:img) }
    end
    context 'when attachment is a file' do
      subject { helper.attachment_icon(pdf_attachment) }
      it { is_expected.to have_tag :span, with: { class: 'icon' } }
      it { is_expected.to match(pdf_attachment.attachment.filename.to_s) }
    end
  end

  describe '#attachment_link' do
    context 'when attachment is an image' do
      subject { helper.attachment_link(image_attachment) }
      it do
        is_expected.to have_tag(
          :a,
          with: {
            href: '#',
            class: 'thumbnail',
            'data-controller' => 'message-train--lightbox',
            'data-lightbox-dialog-id' => 'attachment_preview'
          }
        )
      end
    end
    context 'when attachment is a file' do
      subject { helper.attachment_link(pdf_attachment) }
      it do
        is_expected.to have_tag(:a, with: { class: 'thumbnail' })
      end
    end
  end
end
