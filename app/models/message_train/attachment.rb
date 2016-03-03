module MessageTrain
  # Attachment model
  class Attachment < ActiveRecord::Base
    belongs_to :message, foreign_key: :message_train_message_id, touch: true
    has_attached_file(
      :attachment,
      styles: lambda do |attachment|
        if attachment.instance.image?
          {
            thumb: '235x',
            large: '800x'
          }
        else
          {}
        end
      end,
      path: ':rails_root/public/system/:rails_env/:class/:attachment/'\
        ':id_partition/:style_prefix:filename',
      url: '/system/:rails_env/:class/:attachment/'\
        ':id_partition/:style_prefix:filename',
      convert_options: {
        large: '-quality 75 -interlace Plane -strip',
        thumb: '-quality 75 -strip'
      }
    )
    validates_attachment_presence :attachment
    validates_attachment_content_type(
      :attachment,
      content_type: [
        'application/pdf',
        'application/vnd.ms-excel',
        'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        'application/msword',
        'application/'\
          'vnd.openxmlformats-officedocument.wordprocessingml.document',
        'application/rtf',
        'text/plain',
        %r{^(image|(x-)?application)/(bmp|gif|jpeg|jpg|pjpeg|png|x-png)$}
      ]
    )
    def image?
      # rubocop:disable Style/LineLength
      !(attachment_content_type =~ %r{^(image|(x-)?application)/(bmp|gif|jpeg|jpg|pjpeg|png|x-png)$}).nil?
      # rubocop:enable Style/LineLength
    end

    Paperclip.interpolates :style_prefix do |attachment, style|
      attachment.instance.image? ? "#{style}/" : ''
    end
  end
end
