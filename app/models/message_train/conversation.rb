module MessageTrain
  class Conversation < ActiveRecord::Base
    has_many :messages
    has_many :ignores
    has_many :receipts, through: :messages
    has_many :attachments, through: :messages

    # Scopes
    default_scope { order(updated_at: :desc) }
    scope :ignored, ->(participant) { where(id: ignored_ids_for(participant))}
    scope :unignored, ->(participant) { where.not(id: ignored_ids_for(participant)) }
    scope :with_drafts_by, ->(participant) { joins(:messages).where(message_train_messages: { id: messages.drafts.with_receipts_by(participant) }) }
    scope :with_ready_for, ->(participant) { joins(:messages).where(message_train_messages: { id: messages.ready.with_receipts_for(participant) }) }
    scope :with_messages_for, ->(participant) { joins(:messages).where(message_train_messages: { id: messages.with_receipts_for(participant) }) }
    scope :with_messages_through, ->(participant) { joins(:messages).where(message_train_messages: { id: messages.with_receipts_through(participant) }) }

    def default_recipients_for(sender)
      default_recipients = []
      messages.with_receipts_for(sender).each do |conversation|
        conversation.receipts.each do |receipt|
          default_recipients << receipt.recipient
        end
      end
      default_recipients.delete(sender)
      default_recipients.flatten.uniq
    end

    def set_ignored(participant)
      ignores.first_or_create!(participant: participant)
    end

    def set_unignored(participant)
      ignores.where(participant: participant).destroy_all
    end

    def is_ignored?(participant)
      if ignores.empty?
        false
      else
        !ignores.find_all_by_participant(participant).empty?
      end
    end

    def mark(mark, participant)
      if messages.nil?
        return false
      end
      messages.mark(mark, participant)
    end

    def self.messages
      MessageTrain::Message.joins(:conversation).where(conversation: where(nil))
    end

    def method_missing(method_sym, *arguments, &block)
      # the first argument is a Symbol, so you need to_s it if you want to pattern match
      if method_sym.to_s =~ /^includes_((.*)_(by|to|for|through))\?$/
        case $2
        when 'ready', 'drafts'
          if $3 == 'by'
            !messages.send($2).by(arguments.first).empty?
          else
            !messages.send($2).receipts.send("receipts_#{$3}".to_sym, arguments.first).empty?
          end
        else
          !receipts.send($1.to_sym, arguments.first).empty?
        end
      else
        super
      end
    end

    def self.method_missing(method_sym, *arguments, &block)
      # the first argument is a Symbol, so you need to_s it if you want to pattern match
      if method_sym.to_s =~ /^with_((.*)_(by|to|for|through))$/
        case $2
        when 'ready', 'drafts'
          self.messages.send($2).filter_by_receipt_method("receipts_#{$3}".to_sym, arguments.first).conversations
          when 'messages'
            self.messages.filter_by_receipt_method("receipts_#{$3}".to_sym, arguments.first).conversations
        else
          self.filter_by_receipt_method($1.to_sym, arguments.first)
        end
      else
        super
      end
    end

    # It's important to know Object defines respond_to to take two parameters: the method to check, and whether to include private methods
    # http://www.ruby-doc.org/core/classes/Object.html#M000333
    def respond_to?(method_sym, include_private = false)
      if method_sym.to_s =~ /^includes_((.*)_(by|to|for|through))\?$/
        true
      else
        super
      end
    end

    def self.respond_to?(method_sym, include_private = false)
      if method_sym.to_s =~ /^(.*)_(by|to|for)$/
        true
      else
        super
      end
    end

    private
      scope :filter_by_receipt_method, ->(receipt_method, participant) {
        where(id: where(nil).messages.receipts.send(receipt_method, participant).conversation_ids)
      }

      def self.ignored_ids_for(participant)
        MessageTrain::Ignore.find_all_by_participant(participant).pluck(:conversation_id)
      end
  end
end