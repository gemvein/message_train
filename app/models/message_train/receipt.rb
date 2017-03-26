module MessageTrain
  # Receipt model
  class Receipt < ActiveRecord::Base
    belongs_to :recipient, polymorphic: true
    belongs_to :received_through, polymorphic: true
    belongs_to :message, foreign_key: :message_train_message_id, touch: true
    delegate :conversation, to: :message
    validates_presence_of :recipient, :message

    after_create :notify

    scope :sender_receipt, -> { where(sender: true) }
    scope :recipient_receipt, -> { where(sender: false) }
    scope :for, ->(recipient) { where(recipient: recipient) }
    scope :by, ->(sender) { sender_receipt.for(sender) }
    scope :to, ->(recipient) { recipient_receipt.for(recipient) }
    scope :through, ->(recipient) { where(received_through: recipient) }
    scope :trashed, ->(setting = true) { where(marked_trash: setting) }
    scope :read, ->(setting = true) { where(marked_read: setting) }
    scope :deleted, ->(setting = true) { where(marked_deleted: setting) }
    scope :for_messages, ->(messages) { where(message: messages) }
    scope :flagged, ->(flag, *args) { send(flag.to_sym, *args) }

    def self.message_ids
      pluck(:message_train_message_id)
    end

    def self.messages
      MessageTrain::Message.where(id: message_ids)
    end

    def self.conversation_ids
      messages.conversation_ids
    end

    def self.conversations
      MessageTrain::Conversation.where(id: conversation_ids)
    end

    def self.generate_for_sender(sender)
      first_or_create!(recipient: sender, received_through: sender, sender: 1)
    end

    def self.send_to_or_through(recipient)
      if recipient.class.collective?
        send_through recipient, recipient.class.valid_recipients_method
      else
        send_to recipient
      end
    end

    def self.send_to(recipient)
      receipt = new recipient: recipient, received_through: recipient
      return if receipt.conversation.participant_ignored?(recipient)
      receipt.save
    end

    def self.send_through(recipient, end_recipient_method)
      recipient.send(end_recipient_method).distinct.each do |end_recipient|
        receipt = new recipient: end_recipient, received_through: recipient
        next if receipt.conversation.participant_ignored?(end_recipient) ||
                receipt.message.sender == end_recipient
        receipt.save
      end
    end

    def mark(mark_to_set)
      if mark_to_set.to_s =~ /^un/
        setting = false
        suffix = mark_to_set.to_s.gsub(/^un/, '')
      else
        setting = true
        suffix = mark_to_set.to_s
      end
      column = "marked_#{suffix}".to_sym
      update_attribute(column, setting)
    end

    def self.mark(mark_to_set)
      where(nil).each { |receipt| receipt.mark(mark_to_set) }
    end

    def self.method_missing(method_sym, *args, &block)
      method_string = method_sym.to_s
      if method_string =~ /\A(.*)_(by|to|for|through)\z/
        first_sym = Regexp.last_match[1].to_sym
        second_sym = Regexp.last_match[2].to_sym
        return run_prepositional_method(first_sym, second_sym, *args)
      elsif method_string =~ /\Aun(.*)\z/
        first_sym = Regexp.last_match[1].to_sym
        return run_un_method(first_sym)
      end
      super
    end

    def self.run_prepositional_method(first_sym, second_sym, *args)
      return send(second_sym, *args) if first_sym == :receipts
      send(first_sym).send(second_sym, *args)
    end

    def self.run_un_method(first_sym)
      send(first_sym, false)
    end

    def self.respond_to_missing?(method_sym, include_private = false)
      if method_sym.to_s =~ /\A(.*)_(by|to|for|through)\z/ ||
         method_sym.to_s =~ /\Aun(.*)\z/
        true
      else
        super
      end
    end

    private

    def notify
      return if sender? || recipient.unsubscribed_from?(received_through)
      ReceiptMailer.notification_email(self).deliver_now
    end
  end
end
