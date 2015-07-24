module NightTrain
  class Message < ActiveRecord::Base
    # Relationships
    belongs_to :conversation
    belongs_to :sender, polymorphic: true
    has_many :attachments
    has_many :receipts

    # Accessors
    attr_accessor :recipients_to_save

    # Validations
    validates_presence_of :sender, :subject

    # Callbacks
    before_create :create_conversation_if_blank
    after_create :generate_receipts_or_draft

    def recipients=(value)
      self.recipients_to_save = value
    end

    def recipients
      raw = {}
      receipts.each do |receipt|
        table = receipt.recipient_type.constantize.table_name
        name_column = NightTrain.configuration.name_columns[table.to_sym]
        raw[table] ||= []
        raw[table]<< receipt.recipient.send(name_column)
      end
      results = {}
      raw.each do |key, value|
        results[key] = value.join(', ')
      end
      results
    end

    private
      def create_conversation_if_blank
        if conversation.nil?
          self.conversation = Conversation.create(subject: subject)
        end
      end

      def generate_receipts_or_draft
        recipients_to_save.each do |table, names|
          model = table.classify.constantize
          names.split(',').each do |name|
            name = name.strip
            if NightTrain.configuration.friendly_id_tables.include? table.to_sym
              recipient = model.friendly.find(name)
            else
              name_column = NightTrain.configuration.name_columns[table.to_sym] || :name
              recipient = model.where("#{name_column.to_s} = ?", name).first
            end
            if conversation.ignores.where(recipient: recipient).empty?
              receipts.create!(recipient_type: table.classify, recipient_id: recipient.id)
            end
          end
        end
        reload
        if receipts.empty?
          update_attribute :draft, true
        end
      end
  end
end
