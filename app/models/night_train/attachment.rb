module NightTrain
  class Attachment < ActiveRecord::Base
    belongs_to :message
    has_attached_file :attachment
    validates_attachment_presence :attachment
    validates_attachment_content_type :attachment, content_type: [
                                        "application/pdf",
                                        "application/vnd.ms-excel",
                                        "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
                                        "application/msword",
                                        "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
                                        "application/rtf",
                                        "text/plain",
                                        /^image\/.*$/
                                    ]
  end
end
