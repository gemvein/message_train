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

    after_create :notify

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
