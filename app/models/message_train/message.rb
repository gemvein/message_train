module MessageTrain
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
    after_save :generate_receipts_or_set_draft
    after_save :set_conversation_subject_if_alone

    # Nested Attributes
    accepts_nested_attributes_for :attachments, reject_if: :all_blank, allow_destroy: true

    # Scopes
    default_scope { order('updated_at DESC') }
    scope :filter_by_receipt_method_ids, ->(receipt_method, participant) {
      if count == 0
        []
      else
        all.collect { |x| x.receipts.send(receipt_method, participant).message_ids }.flatten
      end
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
      receipts.recipient_receipt.collect { |x| x.received_through }.uniq
    end

    def self.conversation_ids
      if count == 0
        []
      else
        all.collect { |y| y.conversation_id }
      end
    end

    def self.conversations
      MessageTrain::Conversation.where('id IN (?)', conversation_ids )
    end

    def method_missing(method_sym, *arguments, &block)
      # the first argument is a Symbol, so you need to_s it if you want to pattern match
      if method_sym.to_s =~ /^is_((.*)_(by|to|for|through))\?$/
        !receipts.send($1.to_sym, arguments.first).empty?
      elsif method_sym.to_s =~ /^mark_(.*)_for$/
        receipts.for(arguments.first).first.mark($1.to_sym)
      else
        super
      end
    end

    def self.method_missing(method_sym, *arguments, &block)
      # the first argument is a Symbol, so you need to_s it if you want to pattern match
      if method_sym.to_s =~ /^with_(.*_(by|to|for|through))$/
        filter_by_receipt_method($1.to_sym, arguments.first)
      else
        super
      end
    end

    # It's important to know Object defines respond_to to take two parameters: the method to check, and whether to include private methods
    # http://www.ruby-doc.org/core/classes/Object.html#M000333
    def respond_to?(method_sym, include_private = false)
      if method_sym.to_s =~ /^is_.*_(by|to|for|through)\?$/ || method_sym.to_s =~ /^mark_.*_for\?$/
        true
      else
        super
      end
    end

    def self.respond_to?(method_sym, include_private = false)
      if method_sym.to_s =~ /^.*_(by|to|for|through)$/
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
      receipts.first_or_create!(recipient: sender, received_through: sender, sender: true)
    end

    def generate_receipts_or_set_draft
      unless draft
        recipients_to_save.each do |table, slugs|
          model_name = table.classify
          model = model_name.constantize

          slugs.split(',').each do |slug|
            slug = slug.strip
            slug_column = MessageTrain.configuration.slug_columns[table.to_sym] || :slug
            if model.exists?(slug_column => slug)
              recipient = model.find_by(slug_column => slug)
              end_recipient_method = MessageTrain.configuration.valid_recipients_methods[table.to_sym]
              if end_recipient_method.nil?
                unless conversation.is_ignored?(recipient)
                  receipts.create!(recipient: recipient, received_through: recipient)
                end
              else
                recipient.send(end_recipient_method).each do |end_recipient|
                  unless conversation.is_ignored?(end_recipient) || end_recipient == sender
                    receipts.create!(recipient: end_recipient, received_through: recipient)
                  end
                end
              end
            else
              errors.add :recipients_to_save, :name_not_found.l(name: slug)
            end
          end
        end
        reload
        if recipients.empty?
          update_attribute :draft, true
        else
          conversation.update_attribute(:updated_at, Time.now)
        end
      end
    end

    def set_conversation_subject_if_alone
      if conversation.messages.count == 1
        conversation.update_attribute(:subject, subject)
      end
    end

  end
end
