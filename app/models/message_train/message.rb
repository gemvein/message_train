module MessageTrain
  # Message model
  class Message < ActiveRecord::Base
    # Serializations
    serialize :recipients_to_save, Hash

    attr_accessor :box

    # Relationships
    belongs_to(
      :conversation,
      foreign_key: :message_train_conversation_id,
      class_name: 'MessageTrain::Conversation',
      touch: true
    )
    belongs_to :sender, polymorphic: true
    has_many :attachments, foreign_key: :message_train_message_id
    has_many :receipts, foreign_key: :message_train_message_id
    delegate :participant_ignored?, to: :conversation
    delegate :send_receipts, to: :receipts

    # Validations
    validates_presence_of :sender, :subject

    # Callbacks
    before_create :create_conversation_if_blank
    after_create :generate_sender_receipt
    after_save :generate_receipts_or_set_draft
    after_save :set_conversation_subject_if_alone

    # Nested Attributes
    accepts_nested_attributes_for(
      :attachments, reject_if: :all_blank, allow_destroy: true
    )

    # Scopes
    default_scope { order(updated_at: :desc) }
    scope :ready, -> { where(draft: false) }
    scope :drafts, -> { where(draft: true) }
    scope :by, ->(participant) { where(sender: participant) }
    scope :drafts_by, ->(participant) { drafts.by(participant) }
    scope :filter_by_receipt_method, (lambda do |receipt_method, participant|
      receipts.send(receipt_method, participant).messages
    end)
    scope :for_conversations, ->(c) { where conversation: c }

    def self.conversation_ids
      pluck(:message_train_conversation_id)
    end

    def self.conversations
      MessageTrain::Conversation.where(id: conversation_ids)
    end

    def self.receipts
      MessageTrain::Receipt.for_messages(ids)
    end

    def mark(mark_to_set, participant)
      receipts.for(participant).mark(mark_to_set)
    end

    def self.mark(mark_to_set, participant)
      find_each { |message| message.mark(mark_to_set, participant) }
    end

    def recipients
      receipts.recipient_receipt.map(&:received_through).uniq
    end

    def reply_recipients=(recipients)
      recipient_arrays = {}
      recipients.each do |recipient|
        table_name = recipient.class.table_name
        recipient_arrays[table_name] ||= []
        recipient_arrays[table_name] << recipient.message_train_slug
      end
      recipient_arrays.each do |key, array|
        recipients_to_save[key] = array.join(', ')
      end
    end

    def method_missing(method_sym, *args, &block)
      if method_sym.to_s =~ /^is_((.*)_(by|to|for|through))\?$/
        return receipts.flagged(Regexp.last_match[1], *args).any?
      end
      if method_sym.to_s =~ /^mark_(.*)_for$/
        return mark(Regexp.last_match[1], *args)
      end
      super
    end

    def self.method_missing(method_sym, *args, &block)
      return super unless method_sym.to_s =~ /^with_(.*_(by|to|for|through))$/
      filter_by_receipt_method(Regexp.last_match[1].to_sym, args.first)
    end

    def respond_to_missing?(method_sym, inc_private = false)
      return true if method_sym.to_s =~ /^is_.*_(by|to|for|through)\?$/ ||
                     method_sym.to_s =~ /^mark_.*_for\?$/
      super
    end

    def self.respond_to_missing?(method_sym, inc_private = false)
      method_sym.to_s =~ /^.*_(by|to|for|through)$/ ? true : super
    end

    private

    def create_conversation_if_blank
      return if conversation.present?
      self.conversation = Conversation.create(subject: subject)
    end

    def generate_sender_receipt
      receipts.generate_for_sender(sender)
    end

    def generate_receipts_or_set_draft
      return if draft
      recipients_to_save.each { |table, slugs| save_recipients(table, slugs) }
      recipients.empty? ? update_attribute(:draft, true) : conversation.touch
    end

    def save_recipients(table, slugs)
      slugs = slugs.split(',')
      slugs -= [sender.slug] if sender.class.table_name == table
      slugs.each { |slug| send_receipts(table, slug) }
    end

    def set_conversation_subject_if_alone
      return if conversation.messages.count != 1
      conversation.update_attribute(:subject, subject)
    end

    def send_receipts(table, slug)
      model = table.classify.constantize
      recipient = model.find_by_message_train_slug(slug)
      unless recipient.present?
        errors.add :recipients_to_save, :name_not_found.l(name: slug)
        return
      end
      receipts.send_to_or_through(recipient)
    end
  end
end
