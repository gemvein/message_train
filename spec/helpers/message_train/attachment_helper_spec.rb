require 'rails_helper'

describe MessageTrain::AttachmentsHelper do
  include_context 'loaded site'

  before do
    view.extend BootstrapLeatherHelper
  end

  describe '#attachment_icon' do
    context 'when attachment is an image' do
      subject { helper.attachment_icon(image_attachment) }
      it do
        should have_tag(
          :img,
          with: { src: image_attachment.attachment.url(:thumb) }
        )
      end
    end
    context 'when attachment is a file' do
      subject { helper.attachment_icon(pdf_attachment) }
      it { should have_tag :span, with: { class: 'glyphicon-save-file' } }
    end
  end

  describe '#attachment_link' do
    context 'when attachment is an image' do
      subject { helper.attachment_link(image_attachment) }
      it do
        should have_tag(
          :a,
          with: {
            href: '#',
            class: 'thumbnail',
            'data-toggle' => 'modal',
            'data-target' => '#attachment_preview',
            'data-src' => image_attachment.attachment.url(:large),
            'data-original' => image_attachment.attachment.url(:original),
            'data-text' => 'Click for Original'
          }
        )
      end
    end
    context 'when attachment is a file' do
      subject { helper.attachment_link(pdf_attachment) }
      it do
        should have_tag(
          :a,
          with: { href: pdf_attachment.attachment.url, class: 'thumbnail' }
        )
      end
    end
  end
end
