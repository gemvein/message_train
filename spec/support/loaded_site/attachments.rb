shared_context 'attachments' do
  let(:image_attachment) do
    MessageTrain::Attachment.find_by_attachment_file_name('image-sample.jpg')
  end
  let(:pdf_attachment) do
    MessageTrain::Attachment.find_by_attachment_file_name('pdf-sample.pdf')
  end
end
