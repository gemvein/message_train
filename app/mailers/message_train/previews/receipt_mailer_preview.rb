module MessageTrain
  class ReceiptMailerPreview < ActionMailer::Preview

    def notification_email
      receipt = MessageTrain::Receipt.last
      ReceiptMailer.notification_email(receipt)
    end

  end
end