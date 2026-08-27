module MessageTrain
  # Attachments helper
  module AttachmentsHelper
    def attachment_icon(attachment)
      return image_tag(main_app.url_for(attachment.thumb)) if attachment.image?
      html = content_tag(:span, '', class: 'icon icon-file')
      html << tag(:br) + attachment.attachment.filename.to_s
      html.html_safe
    end

    def attachment_link(attachment)
      render(
        partial: 'message_train/application/attachment_link',
        locals: { attachment: attachment }
      )
    end
  end
end
