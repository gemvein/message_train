shared_context 'attachments' do
  let(:image_attachment) do
    MessageTrain::Attachment
      .joins(:attachment_blob)
      .find_by(active_storage_blobs: { filename: 'image-sample.jpg' })
  end
  let(:pdf_attachment) do
    MessageTrain::Attachment
      .joins(:attachment_blob)
      .find_by(active_storage_blobs: { filename: 'pdf-sample.pdf' })
  end
end
