module NightTrain
  class Message < ActiveRecord::Base
    # Serializations
    serialize :recipients_to_save, Hash

    # Relationships
    belongs_to :conversation
    belongs_to :sender, polymorphic: true
    has_many :attachments
    has_many :receipts

    # Validations
    validates_presence_of :sender, :subject

    # Callbacks
    before_create :create_conversation_if_blank
    after_create :generate_sender_receipt
    after_create :generate_receipts_or_set_draft

    # Scopes
    scope :filter_by_receipt_method_ids, ->(receipt_method, participant) {
      all.collect { |x| x.receipts.send(receipt_method, participant).message_ids }.flatten
    }
    scope :filter_by_receipt_method, ->(receipt_method, participant) {
      where('id IN (?)', filter_by_receipt_method_ids(receipt_method, participant))
    }
    scope :filter_out_by_receipt_method, ->(receipt_method, participant) {
      where('NOT(id IN (?))', filter_by_receipt_method_ids(receipt_method, participant))
    }
    scope :ready, -> { where('draft = ?', false) }
    scope :drafts, -> { where('draft = ?', true) }
    scope :by, ->(participant) { where('sender_type = ? AND sender_id = ?', participant.class.name, participant.id) }
    scope :drafts_by, ->(participant) { drafts.by(participant) }

    def draft=(value)
      if self.draft && !value
        super value
        generate_receipts_or_set_draft
      else
        super value
      end
    end

    def mark(mark_to_set, participant)
      receipt_to_mark = receipts.for(participant).first
      unless receipt_to_mark.nil?
        receipt_to_mark.mark(mark_to_set)
      end
    end

    def self.mark(mark_to_set, participant)
      all.each do |message|
        message.mark(mark_to_set, participant)
      end
    end

    def recipients
      receipts.recipient_receipt.collect { |x| x.recipient }
    end

    def self.conversation_ids
      all.collect { |y| y.conversation_id }
    end

    def self.conversations
      NightTrain::Conversation.where('id IN (?)', conversation_ids )
    end

    def method_missing(method_sym, *arguments, &block)
      # the first argument is a Symbol, so you need to_s it if you want to pattern match
      if method_sym.to_s =~ /^is_((.*)_(by|to|for))\?$/
        !receipts.send($1.to_sym, arguments.first).empty?
      elsif method_sym.to_s =~ /^mark_(.*)_for$/
        receipts.for(arguments.first).first.mark($1.to_sym)
      else
        super
      end
    end

    def self.method_missing(method_sym, *arguments, &block)
      # the first argument is a Symbol, so you need to_s it if you want to pattern match
      if method_sym.to_s =~ /^with_(.*_(by|to|for))$/
        filter_by_receipt_method($1.to_sym, arguments.first)
      else
        super
      end
    end

    # It's important to know Object defines respond_to to take two parameters: the method to check, and whether to include private methods
    # http://www.ruby-doc.org/core/classes/Object.html#M000333
    def respond_to?(method_sym, include_private = false)
      if method_sym.to_s =~ /^is_.*_(by|to|for)\?$/ || method_sym.to_s =~ /^mark_.*_for\?$/
        true
      else
        super
      end
    end

    def self.respond_to?(method_sym, include_private = false)
      if method_sym.to_s =~ /^.*_(by|to|for)$/
        true
      else
        super
      end
    end

    private
      def create_conversation_if_blank
        if conversation.nil?
          self.conversation = Conversation.create(subject: subject)
        end
      end

      def generate_sender_receipt
        receipts.first_or_create!(recipient_type: sender.class.name, recipient_id: sender.id, sender: true)
      end

      def generate_receipts_or_set_draft
        unless draft
          recipients_to_save.each do |table, names|
            model_name = table.classify
            model = model_name.constantize
            names.split(',').each do |name|
              name = name.strip
              if NightTrain.configuration.friendly_id_tables.include? table.to_sym
                recipient = model.friendly.find(name)
              else
                name_column = NightTrain.configuration.name_columns[table.to_sym] || :name
                recipient = model.where(name_column => name).first
              end
              unless conversation.is_ignored?(recipient)
                receipts.create!(recipient_type: model_name, recipient_id: recipient.id)
              end
            end
          end
          reload
          if recipients.empty?
            update_attribute :draft, true
          end
        end
      end
  end
end
