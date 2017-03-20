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

    scope :without_trashed_for, (lambda do |participant|
      joins(:messages).where.not(
        message_train_messages: {
          id: messages.with_trashed_for(participant)
        }
      )
    end)

    scope :without_deleted_for, (lambda do |participant|
      joins(:messages).where.not(
        message_train_messages: {
          id: messages.with_deleted_for(participant)
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
        id: messages.receipts.send(receipt_method, participant)
              .conversation_ids
      )
    end)

    scope :ignored_ids_for, (lambda do |participant|
      MessageTrain::Ignore.find_all_by_participant(participant)
                          .pluck(:message_train_conversation_id)
    end)

    scope :messages, (lambda do
      MessageTrain::Message.for_conversations(ids)
    end)

    scope :filter_by_division, (lambda do |division|
      found = if division == :drafts
                with_drafts_by(participant)
              else
                found with_ready_for(participant)
              end
      if division == :ignored
        found.ignored(participant)
      else
        found.unignored(participant)
      end
    end)

    scope :filter_by_preposition, (lambda do |prep, *args|
      messages.filter_by_receipt_method(prep, *args).conversations
    end)

    scope :filter_by_status_and_preposition, (lambda do |status, prep, *args|
      messages.send(status)
        .filter_by_receipt_method(prep, *args)
        .conversations
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

    def method_missing(method_sym, *args, &block)
      if method_sym.to_s =~ /\Aincludes_((.*)_(by|to|for|through))\?\z/
        return includes_matches_with_preposition?(
          Regexp.last_match[2].to_sym,
          Regexp.last_match[3].to_sym,
          *args
        )
      end
      super
    end

    def includes_matches_with_preposition?(flag, prep, *args)
      unless [:ready, :drafts].include? flag
        return includes_matching_receipts?(
          "#{flag}_#{prep}".to_sym,
          *args
        )
      end
      return includes_matching_messages_by?(flag, *args) if prep == 'by'
      includes_matching_messages_with_prep?(flag, prep, *args)
    end

    def includes_matching_receipts?(match_method_sym, *args)
      receipts.send(match_method_sym, *args).any?
    end

    def respond_to_missing?(method_sym, include_private = false)
      if method_sym.to_s =~ /\Aincludes_((.*)_(by|to|for|through))\?\z/
        true
      else
        super
      end
    end

    def self.method_missing(method_sym, *args, &block)
      if method_sym.to_s =~ /^with_((.*)_(by|to|for|through))$/
        status_sym = Regexp.last_match[2].to_sym
        preposition_sym = Regexp.last_match[3].to_sym
        case status_sym
        when :ready, :drafts
          return filter_by_status_and_preposition(
            status_sym,
            preposition_sym,
            *args
          )
        when :messages
          return filter_by_preposition(preposition_sym, *args)
        else
          return filter_by_receipt_method(Regexp.last_match[1].to_sym, *args)
        end
      end
      super
    end

    def self.respond_to_missing?(method_sym, include_private = false)
      if method_sym.to_s =~ /^with_(.*)_(by|to|for|through)$/
        true
      else
        super
      end
    end

    protected

    def includes_matching_messages_by?(flag, *args)
      messages.send(flag).by(*args).any?
    end

    def includes_matching_messages_with_prep?(flag, preposition, *args)
      messages.send(flag).receipts.send(
        "receipts_#{preposition}".to_sym,
        *args
      ).any?
    end
  end
end
