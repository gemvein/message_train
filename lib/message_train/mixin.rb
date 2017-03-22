module MessageTrain
  # Mixin module automatically extended by ActiveRecord::Base
  module Mixin
    extend ActiveSupport::Concern

    # Run message_train mixin in your model to enable
    def message_train(options = {})
      cattr_accessor :message_train_table_sym, :message_train_relationships
      table_sym = table_name.to_sym

      relationships = [options.delete(:only) || [:sender, :recipient]].flatten
      relationships -= [options.delete(:except) || []].flatten

      associations_from_relationships(relationships)

      MessageTrain.configure_table(table_sym, name, options)

      self.message_train_relationships = relationships
      self.message_train_table_sym = table_sym

      extend ClassMethods
      include InstanceMethods::GeneralMethods
    end

    def associations_from_relationships(relationships)
      if relationships.include? :sender
        has_many :messages, as: :sender, class_name: 'MessageTrain::Message'
      end
      return unless relationships.include? :recipient
      has_many :receipts, as: :recipient, class_name: 'MessageTrain::Receipt'
      has_many(
        :unsubscribes,
        as: :recipient,
        class_name: 'MessageTrain::Unsubscribe'
      )
    end

    # Extended when message_train mixin is run
    module ClassMethods
      def message_train_address_book(for_participant)
        method = MessageTrain.configuration.address_book_methods[
          message_train_table_sym
        ]
        method ||= MessageTrain.configuration.address_book_method
        if method.present? && respond_to?(method)
          send(method, for_participant)
        else
          all
        end
      end

      def where_slug_starts_with(string)
        return where(nil) unless string.present?
        field_name = MessageTrain.configuration.slug_columns[
          message_train_table_sym
        ]
        pattern = Regexp.union('\\', '%', '_')
        string = string.gsub(pattern) { |x| ['\\', x].join }
        where("#{field_name} LIKE ?", "#{string}%")
      end
    end

    # Not included directly: instead, children are included
    module InstanceMethods
      # Included in method when message_train mixin is run
      module GeneralMethods
        BOX_DEFINITIONS = {
          in: :with_untrashed_to,
          sent: :with_untrashed_by,
          all: :with_untrashed_for,
          drafts: :with_drafts_by,
          trash: :with_trashed_for,
          ignored: :ignored
        }.freeze

        BOX_OMISSION_DEFINITIONS = {
          trash: :without_trashed_for,
          drafts: :with_ready_for,
          ignored: :unignored
        }.freeze

        def self.included(base)
          base.message_train_relationships.include?(:recipient) &&
            base.send(:include, InstanceMethods::RecipientMethods)
        end

        def slug_part
          send(
            MessageTrain.configuration.slug_columns[
              self.class.message_train_table_sym
            ] || :slug
          )
        end

        def path_part
          if MessageTrain.configuration.valid_senders_methods[
            self.class.message_train_table_sym
          ].present?
            # This must mean it's a collective
            "#{self.class.table_name}:#{slug_part}"
          end
        end

        def valid_senders
          send(
            MessageTrain.configuration.valid_senders_methods[
              self.class.table_name.to_sym
            ] || :self_collection
          )
        end

        def allows_sending_by?(sender)
          valid_senders.include? sender
        end

        def valid_recipients
          send(
            MessageTrain.configuration.valid_recipients_methods[
              self.class.table_name.to_sym
            ] || :self_collection
          )
        end

        def allows_access_by?(recipient)
          allows_receiving_by?(recipient) || allows_sending_by?(recipient)
        end

        def allows_receiving_by?(recipient)
          if valid_recipients.nil? || valid_recipients.empty?
            false
          else
            valid_recipients.include? recipient
          end
        end

        def self_collection
          # This turns a single record into an active record collection.
          model = self.class
          model.where(id: id)
        end

        def conversations(*args)
          division = args[0] || :in
          participant = args[1] || self
          definition_method = BOX_DEFINITIONS[division]
          return if definition_method.nil?
          conversations = defined_conversations(definition_method, participant)
          BOX_OMISSION_DEFINITIONS.each do |division_key, omission_method|
            next if division_key == division # Because not to be omitted
            conversations = conversations.send(omission_method, participant)
          end
          conversations
        end

        def defined_conversations(definition, participant)
          MessageTrain::Conversation.with_messages_through(self)
                                    .without_deleted_for(participant)
                                    .send(definition, participant)
        end

        def boxes_for_participant(participant)
          original_order = [:in, :sent, :all, :drafts, :trash, :ignored]
          divisions = [:all, :trash]
          if respond_to?(:messages) || allows_sending_by?(participant)
            divisions += [:sent, :drafts]
          end
          allows_receiving_by?(participant) && divisions += [:in, :ignored]
          divisions.sort_by! { |x| original_order.index x }
          divisions.collect do |division|
            MessageTrain::Box.new(self, division, participant)
          end
        end

        def all_conversations(*args)
          participant = args[0] || self
          results = MessageTrain::Conversation.with_messages_through(self)
          return [] if results.empty?
          results.with_messages_for(participant)
        end

        def all_messages(*args)
          participant = args[0] || self
          results = MessageTrain::Message.with_receipts_through(self)
          return [] if results.empty?
          results.with_receipts_for(participant)
        end

        def unsubscribed_from_all?
          unsubscribes.where(from: nil).exists?
        end

        def unsubscribed_from?(from)
          unsubscribed_from_all? || unsubscribes.where(from: from).exists?
        end

        def unsubscribe_from(from)
          unsubscribes.find_or_create_by(from: from)
        end

        def subscriptions
          subscriptions = []
          subscriptions << self_subscription
          collective_boxes.values.each do |boxes|
            boxes.each do |box|
              subscriptions << subscription(box)
            end
          end
          subscriptions.compact
        end
      end

      # Included by GeneralMethods when message_train mixin is run, if this is a
      # recipient
      module RecipientMethods
        def box(*args)
          division = args[0] || :in
          participant = args[1] || self
          @box ||= MessageTrain::Box.new(self, division, participant)
        end

        def collective_boxes(*args)
          division = args[0] || :in
          participant = args[1] || self
          cb_tables = MessageTrain.configuration
                                  .collectives_for_recipient_methods
          return {} if cb_tables.empty?
          Hash[cb_tables.map do |key, value|
            box = table_collective_box(key, value, division, participant)
            [key, box]
          end]
        end

        def collective_boxes_unread_counts
          Hash[collective_boxes.map do |key, collectives|
            [key, collectives.collect(&:unread_count).sum]
          end]
        end

        def collective_boxes_show_flags
          Hash[collective_boxes.map do |key, collectives|
            flag = collectives.select do |collective_box|
              collective_box.parent.allows_access_by?(self)
            end.any?
            [key, flag]
          end]
        end

        def table_collective_box(
          table_sym, collectives_method, division, participant
        )
          model = MessageTrain.configuration.recipient_tables[table_sym]
                              .constantize
          collectives = model.send(collectives_method, participant)
          collectives.map { |x| x.box(division, participant) }.compact
        end

        def all_boxes(*args)
          participant = args[0] || self
          divisions = [:in, :sent, :all, :drafts, :trash, :ignored]
          divisions.collect do |division|
            MessageTrain::Box.new(self, division, participant)
          end
        end

        def message_train_name
          send MessageTrain.configuration.name_columns[
                 self.class.message_train_table_sym
               ]
        end

        def message_train_slug
          send MessageTrain.configuration.slug_columns[
                 self.class.message_train_table_sym
               ]
        end

        protected

        def self_subscription
          {
            from: self, from_type: self.class.name, from_id: id,
            from_name: :messages_directly_to_myself.l,
            unsubscribe: unsubscribes.find_by(from: self)
          }
        end

        def subscription(box)
          parent = box.parent
          return unless parent.allows_receiving_by?(self)
          {
            from: parent, from_type: parent.class.name, from_id: parent.id,
            from_name: :messages_to_collective.l(
              collective: parent.message_train_name
            ),
            unsubscribe: unsubscribes.find_by(from: parent)
          }
        end
      end
    end
  end
end
