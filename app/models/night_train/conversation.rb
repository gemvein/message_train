module NightTrain
  class Conversation < ActiveRecord::Base
    has_many :messages
    has_many :ignores
    has_many :receipts, through: :messages

    scope :ignored, ->(participant) { where('id IN (?)', ignored_ids_for(participant))}
    scope :unignored, ->(participant) { where('NOT(id IN (?))', ignored_ids_for(participant))}
    scope :filter_by_receipt_method_ids, ->(receipt_method, participant) {
      all.collect { |x| x.receipts.send(receipt_method, participant).conversation_ids }.flatten
    }
    scope :filter_by_receipt_method, ->(receipt_method, participant) {
      where('id IN (?)', filter_by_receipt_method_ids(receipt_method, participant))
    }

    def set_ignored(participant)
      ignores.first_or_create!(participant: participant)
    end

    def is_ignored?(participant)
     !ignores.find_all_by_participant(participant).empty?
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
  end

  private

    def ignored_ids_of(participant)
      ignores.of(participant).conversation_ids
    end
end