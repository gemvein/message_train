module MessageTrain
  # Receipt model
  class Receipt < ActiveRecord::Base
    belongs_to :recipient, polymorphic: true
    belongs_to :received_through, polymorphic: true
    belongs_to(
      :message,
      foreign_key: :message_train_message_id,
      touch: true
    )
    validates_presence_of :recipient, :message

    default_scope { order(updated_at: :desc) }
    scope :sender_receipt, -> { where(sender: true) }
    scope :recipient_receipt, -> { where(sender: false) }
    scope :by, ->(sender) { sender_receipt.for(sender) }
    scope :for, (lambda do |recipient|
      where(recipient: recipient)
    end)
    scope :to, ->(recipient) { recipient_receipt.for(recipient) }
    scope :through, (lambda do |received_through|
      where(received_through: received_through)
    end)
    scope :trashed, ->(setting = true) { where(marked_trash: setting) }
    scope :read, ->(setting = true) { where(marked_read: setting) }
    scope :deleted, ->(setting = true) { where(marked_deleted: setting) }
    scope :for_messages, (lambda do |messages|
      where(message: messages)
    end)

    after_create :notify

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

    def self.message_ids
      pluck(:message_train_message_id)
    end

    def self.messages
      MessageTrain::Message.joins(:receipts)
                           .where(message_train_receipts: { id: where(nil) })
    end

    def self.conversation_ids
      messages.conversation_ids
    end

    def self.conversations
      MessageTrain::Conversation.joins(:receipts)
                                .where(
                                  message_train_receipts: { id: where(nil) }
                                )
    end

    def self.method_missing(method_sym, *arguments, &block)
      # the first argument is a Symbol, so you need to_s it if you want to
      # pattern match
      if method_sym.to_s =~ /^receipts_(by|to|for|through)$/
        send(Regexp.last_match[1].to_sym, arguments.first)
      elsif method_sym.to_s =~ /^(.*)_(by|to|for|through)$/
        send(Regexp.last_match[1].to_sym)
          .send(Regexp.last_match[2].to_sym, arguments.first)
      elsif method_sym.to_s =~ /^un(.*)$/
        send(Regexp.last_match[1].to_sym, false)
      else
        super
      end
    end

    def self.respond_to_missing?(method_sym, include_private = false)
      if method_sym.to_s =~ /^(.*)_(by|to|for|through)$/ ||
         method_sym.to_s =~ /^un(.*)$/
        true
      else
        super
      end
    end

    private

    def notify
      return if sender? || recipient.unsubscribed_from?(received_through)
      ReceiptMailer.notification_email(self).deliver_later
    end
  end
end
