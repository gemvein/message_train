module MessageTrain
  # Attachments helper
  module AttachmentsHelper
    def attachment_icon(attachment)
      return image_tag(attachment.attachment.url(:thumb)) if attachment.image?
      icon_class = 'glyphicon glyphicon-save-file glyphicon-thumbnail'
      html = content_tag(:span, '', class: icon_class)
      html << tag(:br) + attachment.attachment_file_name
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
