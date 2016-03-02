module MessageTrain
  # Receipt mailer
  class ReceiptMailer < ApplicationMailer
    def notification_email(receipt)
      @receipt = receipt
      @recipient = receipt.recipient
      @through = receipt.received_through
      if @recipient == @through
        @heading = :new_message_on_site_name.l(
          site_name: MessageTrain.configuration.site_name
        )
      else
        @through_name = @through.send(
          MessageTrain.configuration.name_columns[
            @through.class.table_name.to_sym
          ]
        )
        @heading = :new_message_through_on_site_name.l(
          site_name: MessageTrain.configuration.site_name,
          through: @through_name
        )
      end
      @subject = "#{@heading}: #{@receipt.message.subject}"
      mail(to: @recipient.email, subject: @subject)
    end
  end
end
