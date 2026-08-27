module MessageTrain
  module Previews
    # Receipt mailer preview
    class ReceiptMailerPreview < ActionMailer::Preview
      def notification_email
        receipt = MessageTrain::Receipt.last
        MessageTrain::ReceiptMailer.notification_email(receipt)
      end
    end
  end
end
