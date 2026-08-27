module MessageTrain
  # Attachment model
  class Attachment < ActiveRecord::Base
    ALLOWED_CONTENT_TYPES = [
      'application/pdf',
      'application/vnd.ms-excel',
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      'application/msword',
      'application/'\
        'vnd.openxmlformats-officedocument.wordprocessingml.document',
      'application/rtf',
      'text/plain',
      %r{^(image|(x-)?application)/(bmp|gif|jpeg|jpg|pjpeg|png|x-png)$}
    ].freeze

    belongs_to :message, foreign_key: :message_train_message_id, touch: true
    has_one_attached :attachment

    validate :attachment_must_be_present
    validate :attachment_content_type_must_be_allowed

    def image?
      attached_content_type = attachment.content_type
      !(attached_content_type =~ %r{^(image|(x-)?application)/(bmp|gif|jpeg|jpg|pjpeg|png|x-png)$}).nil?
    end

    def thumb
      attachment.variant(
        resize_to_limit: [235, 235],
        saver: { quality: 75, strip: true }
      )
    end

    def large
      attachment.variant(
        resize_to_limit: [800, 800],
        saver: { quality: 75, strip: true, interlace: 'Plane' }
      )
    end

    private

    def attachment_must_be_present
      errors.add(:attachment, :blank) unless attachment.attached?
    end

    def attachment_content_type_must_be_allowed
      return unless attachment.attached?

      content_type = attachment.content_type
      allowed = ALLOWED_CONTENT_TYPES.any? do |allowed_type|
        allowed_type.is_a?(Regexp) ? allowed_type.match?(content_type) : allowed_type == content_type
      end
      errors.add(:attachment, :content_type_invalid) unless allowed
    end
  end
end
