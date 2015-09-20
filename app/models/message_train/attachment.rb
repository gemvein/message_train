module MessageTrain
  class Attachment < ActiveRecord::Base
    belongs_to :message
    has_attached_file :attachment, styles: lambda { |attachment|
                                                    attachment.instance.image? ? {
                                                      thumb: '235x',
                                                      large: '800x'
                                                    } : {}
                                                  },
                                  path: ':rails_root/public/system/:rails_env/:class/:attachment/:id_partition/:style_prefix:filename',
                                  url: '/system/:rails_env/:class/:attachment/:id_partition/:style_prefix:filename',
                                  convert_options: {
                                      large: '-quality 75 -interlace Plane -strip',
                                      thumb: '-quality 75 -strip',
                                  }
    validates_attachment_presence :attachment
    validates_attachment_content_type :attachment, content_type: [
                                        'application/pdf',
                                        'application/vnd.ms-excel',
                                        'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
                                        'application/msword',
                                        'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
                                        'application/rtf',
                                        'text/plain',
                                        /^(image|(x-)?application)\/(bmp|gif|jpeg|jpg|pjpeg|png|x-png)$/
                                    ]
    def image?
      (attachment_content_type =~ /^(image|(x-)?application)\/(bmp|gif|jpeg|jpg|pjpeg|png|x-png)$/) ? true : false
    end

    Paperclip.interpolates :style_prefix do |attachment, style|
      attachment.instance.image? ? "#{style.to_s}/" : ''
    end
  end
end