module MessageTrain
  module AttachmentsHelper
    def attachment_icon(attachment)
      html = ""
      if attachment.image?
        html << image_tag(attachment.attachment.url(:thumb))
      else
        html << content_tag(:span, '', class: 'glyphicon glyphicon-save-file glyphicon-thumbnail')
        html << tag(:br)
        html << attachment.attachment_file_name
      end
      html.html_safe
    end

    def attachment_link(attachment)
      render partial: 'attachment_link', locals: { attachment: attachment }
    end
  end
end