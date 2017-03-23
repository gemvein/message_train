module MessageTrain
  # Receipt mailer
  class ReceiptMailer < ApplicationMailer
    def notification_email(receipt)
      @receipt = receipt
      @recipient = receipt.recipient
      @through = receipt.received_through
      if @recipient == @through
        set_self_heading
      else
        set_through_heading
      end
      @subject = "#{@heading}: #{@receipt.message.subject}"
      mail(to: @recipient.email, subject: @subject)
    end

    private

    def set_self_heading
      @heading = :new_message_on_site_name.l(
        site_name: MessageTrain.configuration.site_name
      )
    end

    def set_through_heading
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
  end
end
