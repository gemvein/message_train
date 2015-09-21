module MessageTrain
  class Receipt < ActiveRecord::Base
    belongs_to :recipient, polymorphic: true
    belongs_to :received_through, polymorphic: true
    belongs_to :message
    validates_presence_of :recipient, :message

    default_scope { order("created_at DESC") }
    scope :sender_receipt, -> { where('sender = ?', true) }
    scope :recipient_receipt, -> { where('sender = ?', false) }
    scope :by, ->(sender) { sender_receipt.for(sender) }
    scope :for, ->(recipient) { where('recipient_type = ? AND recipient_id = ?', recipient.class.name, recipient.id) }
    scope :to, ->(recipient) { recipient_receipt.for(recipient) }
    scope :through, ->(received_through) { where('received_through_type = ? AND received_through_id = ?', received_through.class.name, received_through.id) }
    scope :trashed, ->(setting = true) { where('marked_trash = ?', setting) }
    scope :read, ->(setting = true) { where('marked_read = ?', setting) }
    scope :deleted, ->(setting = true) { where('marked_deleted = ?', setting) }

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
      all.collect { |y| y.message_id }
    end

    def self.messages
      MessageTrain::Message.where('id IN (?)', message_ids )
    end

    def self.conversation_ids
      if all.nil? || all.empty?
        []
      else
        all.collect { |y| y.message.conversation_id }
      end
    end

    def self.conversations
      MessageTrain::Conversation.where('id IN (?)', conversation_ids )
    end

    def self.method_missing(method_sym, *arguments, &block)
      # the first argument is a Symbol, so you need to_s it if you want to pattern match
      if method_sym.to_s =~ /^receipts_(by|to|for|through)$/
        send($1.to_sym, arguments.first)
      elsif method_sym.to_s =~ /^(.*)_(by|to|for|through)$/
        send($1.to_sym).send($2.to_sym, arguments.first)
      elsif method_sym.to_s =~ /^mark_(.*)$/
        mark($1.to_sym)
      elsif method_sym.to_s =~ /^un(.*)$/
        send($1.to_sym, false)
      else
        super
      end
    end

    # It's important to know Object defines respond_to to take two parameters: the method to check, and whether to include private methods
    # http://www.ruby-doc.org/core/classes/Object.html#M000333
    def self.respond_to?(method_sym, include_private = false)
      if method_sym.to_s =~ /^(.*)_(by|to|for|through)$/ || method_sym.to_s =~ /^(un|mark_)(.*)$/
        true
      else
        super
      end
    end
  end
end
