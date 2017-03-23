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

    # Validations
    validates_presence_of :sender, :subject

    # Callbacks
    before_create :create_conversation_if_blank
    after_create :generate_sender_receipt
    after_save :generate_receipts_or_set_draft
    after_save :set_conversation_subject_if_alone

    # Nested Attributes
    accepts_nested_attributes_for(
      :attachments,
      reject_if: :all_blank,
      allow_destroy: true
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
    scope :for_conversations, (lambda do |conversations|
      where(conversation: conversations)
    end)

    def self.conversation_ids
      pluck(:message_train_conversation_id)
    end

    def self.receipts
      MessageTrain::Receipt.for_messages(ids)
    end

    def self.conversations
      MessageTrain::Conversation.where(id: conversation_ids)
    end

    def mark(mark_to_set, participant)
      receipt_to_mark = receipts.for(participant).first
      receipt_to_mark.present? && receipt_to_mark.mark(mark_to_set)
    end

    def self.mark(mark_to_set, participant)
      find_each do |message|
        message.mark(mark_to_set, participant)
      end
    end

    def recipients
      recips = []
      receipts.recipient_receipt.each do |message|
        recips << message.received_through
      end
      recips.uniq
    end

    def self.new_message(args = {})
      if args[:message_train_conversation_id].nil?
        MessageTrain::Message.new(args)
      else
        MessageTrain::Message.new_reply(args)
      end
    end

    def self.new_reply(args)
      box = args[:box]
      conversation = box.find_conversation(args[:message_train_conversation_id])
      previous_message = conversation.messages.last
      message = conversation.messages.build(args)
      message.subject = "Re: #{conversation.subject}"
      message.body = "<blockquote>#{previous_message.body}</blockquote>"\
          '<p>&nbsp;</p>'
      default_recipients = conversation.default_recipients_for(box.parent)
      set_reply_recipients(message, default_recipients)
    end

    def self.set_reply_recipients(message, recipients)
      recipient_arrays = {}
      recipients.each do |recipient|
        table_name = recipient.class.table_name
        recipient_arrays[table_name] ||= []
        recipient_arrays[table_name] << recipient.message_train_slug
      end
      recipient_arrays.each do |key, array|
        message.recipients_to_save[key] = array.join(', ')
      end
      message
    end

    def method_missing(method_sym, *args, &block)
      method_string = method_sym.to_s

      if method_string =~ /^is_((.*)_(by|to|for|through))\?$/
        return matching_receipts_exist?(Regexp.last_match[1], *args)
      end

      if method_string =~ /^mark_(.*)_for$/
        return mark_matching_receipts(Regexp.last_match[1], *args)
      end

      super
    end

    def self.method_missing(method_sym, *arguments, &block)
      # the first argument is a Symbol, so you need to_s it if you want to
      # pattern match
      if method_sym.to_s =~ /^with_(.*_(by|to|for|through))$/
        filter_by_receipt_method(Regexp.last_match[1].to_sym, arguments.first)
      else
        super
      end
    end

    def respond_to_missing?(method_sym, include_private = false)
      if method_sym.to_s =~ /^is_.*_(by|to|for|through)\?$/ ||
         method_sym.to_s =~ /^mark_.*_for\?$/
        true
      else
        super
      end
    end

    def self.respond_to_missing?(method_sym, include_private = false)
      if method_sym.to_s =~ /^.*_(by|to|for|through)$/
        true
      else
        super
      end
    end

    private

    def create_conversation_if_blank
      return if conversation.present?
      self.conversation = Conversation.create(subject: subject)
    end

    def generate_sender_receipt
      receipts.first_or_create!(
        recipient: sender,
        received_through: sender,
        sender: true
      )
    end

    def generate_receipts_or_set_draft
      return if draft
      recipients_to_save.each do |table, slugs|
        save_recipients(table, slugs)
      end
      reload
      if recipients.empty?
        update_attribute :draft, true
      else
        conversation.touch
      end
    end

    def save_recipients(table, slugs)
      slugs = slugs.split(',')
      sender.class.table_name == table && (slugs -= [sender.slug])
      slugs.each do |slug|
        send_receipts(table, slug)
      end
    end

    def set_conversation_subject_if_alone
      return if conversation.messages.count != 1
      conversation.update_attribute(:subject, subject)
    end

    def send_receipts(table, slug)
      recipient = get_recipient table, slug || return

      end_recipient_method = MessageTrain.configuration
                                         .valid_recipients_methods[table.to_sym]
      if end_recipient_method.present?
        send_receipts_through(recipient, end_recipient_method)
      else
        send_receipt_to(recipient)
      end
    end

    def get_recipient(table, slug)
      model = table.classify.constantize
      slug = slug.strip
      slug_column = MessageTrain.configuration
                                .slug_columns[table.to_sym] || :slug

      recipient = model.find_by(slug_column => slug)
      unless recipient.present?
        errors.add :recipients_to_save, :name_not_found.l(name: slug)
        return
      end
      recipient
    end

    def send_receipt_to(recipient)
      return if conversation.participant_ignored?(recipient)
      receipts.create!(
        recipient: recipient,
        received_through: recipient
      )
    end

    def send_receipts_through(recipient, end_recipient_method)
      recipient.send(end_recipient_method).distinct.each do |end_recipient|
        next if conversation.participant_ignored?(end_recipient) ||
                end_recipient == sender
        receipts.create!(
          recipient: end_recipient,
          received_through: recipient
        )
      end
    end

    def matching_receipts_exist?(flag, *args)
      receipts.send(flag.to_sym, *args).any?
    end

    def mark_matching_receipts(flag, *args)
      receipts.for(*args).first.mark(flag.to_sym)
    end
  end
end
