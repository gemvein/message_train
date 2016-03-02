module MessageTrain
  # Conversation model
  class Conversation < ActiveRecord::Base
    has_many :messages, foreign_key: :message_train_conversation_id
    has_many :ignores, foreign_key: :message_train_conversation_id
    has_many :receipts, through: :messages
    has_many :attachments, through: :messages

    # Scopes
    default_scope { order(updated_at: :desc) }
    scope :ignored, ->(participant) { where(id: ignored_ids_for(participant)) }
    scope :unignored, (lambda do |participant|
      where.not(id: ignored_ids_for(participant))
    end)
    scope :with_drafts_by, (lambda do |participant|
      joins(:messages).where(
        message_train_messages: {
          id: messages.drafts.with_receipts_by(participant)
        }
      )
    end)
    scope :with_ready_for, (lambda do |participant|
      joins(:messages).where(
        message_train_messages: {
          id: messages.ready.with_receipts_for(participant)
        }
      )
    end)
    scope :with_messages_for, (lambda do |participant|
      joins(:messages).where(
        message_train_messages: {
          id: messages.with_receipts_for(participant)
        }
      )
    end)
    scope :with_messages_through, (lambda do |participant|
      joins(:messages).where(
        message_train_messages: {
          id: messages.with_receipts_through(participant)
        }
      )
    end)

    scope :filter_by_receipt_method, (lambda do |receipt_method, participant|
      where(
        id: where(nil).messages.receipts.send(receipt_method, participant)
              .conversation_ids
      )
    end)

    scope :ignored_ids_for, (lambda do |participant|
      MessageTrain::Ignore.find_all_by_participant(participant)
                          .pluck(:message_train_conversation_id)
    end)

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

    def participant_ignore(participant)
      ignores.first_or_create!(participant: participant)
    end

    def participant_unignore(participant)
      ignores.where(participant: participant).destroy_all
    end

    def participant_ignored?(participant)
      if ignores.empty?
        false
      else
        !ignores.find_all_by_participant(participant).empty?
      end
    end

    def mark(mark, participant)
      messages.mark(mark, participant)
    end

    def self.messages
      MessageTrain::Message.joins(:conversation).where(conversation: where(nil))
    end

    def method_missing(method_sym, *arguments, &block)
      # the first argument is a Symbol, so you need to_s it if you want to
      # pattern match
      if method_sym.to_s =~ /^includes_((.*)_(by|to|for|through))\?$/
        case Regexp.last_match[2]
        when 'ready', 'drafts'
          if Regexp.last_match[3] == 'by'
            messages.send(Regexp.last_match[2]).by(arguments.first).any?
          else
            messages.send(Regexp.last_match[2]).receipts.send(
              "receipts_#{Regexp.last_match[3]}".to_sym,
              arguments.first
            ).any?
          end
        else
          receipts.send(Regexp.last_match[1].to_sym, arguments.first).any?
        end
      else
        super
      end
    end

    def self.method_missing(method_sym, *arguments, &block)
      # the first argument is a Symbol, so you need to_s it if you want to
      # pattern match
      if method_sym.to_s =~ /^with_((.*)_(by|to|for|through))$/
        case Regexp.last_match[2]
        when 'ready', 'drafts'
          messages.send(
            Regexp.last_match[2]
          ).filter_by_receipt_method(
            "receipts_#{Regexp.last_match[3]}".to_sym,
            arguments.first
          ).conversations
        when 'messages'
          messages.filter_by_receipt_method(
            "receipts_#{Regexp.last_match[3]}".to_sym,
            arguments.first
          ).conversations
        else
          filter_by_receipt_method(
            Regexp.last_match[1].to_sym,
            arguments.first
          )
        end
      else
        super
      end
    end

    # It's important to know Object defines respond_to to take two parameters:
    # the method to check, and whether to include private methods
    # http://www.ruby-doc.org/core/classes/Object.html#M000333
    def respond_to?(method_sym, include_private = false)
      if method_sym.to_s =~ /^includes_((.*)_(by|to|for|through))\?$/
        true
      else
        super
      end
    end

    def self.respond_to?(method_sym, include_private = false)
      if method_sym.to_s =~ /^with_(.*)_(by|to|for|through)$/
        true
      else
        super
      end
    end
  end
end
