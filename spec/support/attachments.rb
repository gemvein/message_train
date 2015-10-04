shared_context 'attachments' do
  let(:image_attachment) { MessageTrain::Attachment.find_by("attachment_file_name LIKE '%image-sample.jpg'") }
  let(:pdf_attachment) { MessageTrain::Attachment.find_by("attachment_file_name LIKE '%pdf-sample.pdf'") }
end