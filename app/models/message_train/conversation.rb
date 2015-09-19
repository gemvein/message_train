module MessageTrain
  class Conversation < ActiveRecord::Base
    has_many :messages
    has_many :ignores
    has_many :receipts, through: :messages
    has_many :attachments, through: :messages

    # Scopes
    default_scope { order('updated_at DESC') }
    scope :ignored, ->(participant) { where('id IN (?)', ignored_ids_for(participant))}
    scope :unignored, ->(participant) {
      ignored_ids = ignored_ids_for(participant)
      if ignored_ids.empty?
        all
      else
        where('NOT(id IN (?))', ignored_ids)
      end
    }
    scope :filter_by_receipt_method_ids, ->(receipt_method, participant) {
      all.collect { |x| x.receipts.send(receipt_method, participant).conversation_ids }.flatten.uniq
    }
    scope :filter_by_receipt_method, ->(receipt_method, participant) {
      where('id IN (?)', filter_by_receipt_method_ids(receipt_method, participant))
    }
    scope :with_drafts_by, ->(participant) {
      ids_with_drafts = all.collect { |x| x.messages.drafts.by(participant).conversation_ids }.flatten.uniq
      where('id IN (?)', ids_with_drafts)
    }
    scope :with_ready_for, ->(participant) {
      ids_with_ready = all.collect { |x| x.messages.ready.with_receipts_for(participant).conversation_ids }.flatten.uniq
      where('id IN (?)', ids_with_ready)
    }
    scope :with_messages_for, ->(participant) {
      ids_for = all.collect { |x| x.messages.with_receipts_for(participant).conversation_ids }.flatten.uniq
      where('id IN (?)', ids_for)
    }
    scope :with_messages_through, ->(participant) {
      ids_for = all.collect { |x| x.messages.with_receipts_through(participant).conversation_ids }.flatten.uniq
      where('id IN (?)', ids_for)
    }

    def default_recipients_for(sender)
      recipients = messages.with_receipts_for(sender)
                       .collect { |x| x.receipts.collect { |y| y.recipient } }
                       .flatten
                       .uniq
      recipients.delete(sender)
      recipients
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
      messages.mark(mark, participant)
    end

    def includes_drafts_by?(participant)
      !messages.drafts_by(participant).empty?
    end

    def method_missing(method_sym, *arguments, &block)
      # the first argument is a Symbol, so you need to_s it if you want to pattern match
      if method_sym.to_s =~ /^includes_(.*_(by|to|for))\?$/
        !receipts.send($1.to_sym, arguments.first).empty?
      else
        super
      end
    end

    def self.method_missing(method_sym, *arguments, &block)
      # the first argument is a Symbol, so you need to_s it if you want to pattern match
      if method_sym.to_s =~ /^with_((.*)_(by|to|for))$/
        self.filter_by_receipt_method($1.to_sym, arguments.first)
      else
        super
      end
    end

    # It's important to know Object defines respond_to to take two parameters: the method to check, and whether to include private methods
    # http://www.ruby-doc.org/core/classes/Object.html#M000333
    def respond_to?(method_sym, include_private = false)
      if method_sym.to_s =~ /^includes_((.*)_(by|to|for))\?$/
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

      def self.ignored_ids_for(participant)
        MessageTrain::Ignore.find_all_by_participant(participant).conversation_ids
      end
  end
end