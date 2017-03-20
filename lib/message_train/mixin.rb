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

      associations_from_relationships(relationships, table_sym)

      MessageTrain.configure_table(table_sym, options)

      self.message_train_relationships = relationships
      self.message_train_table_sym = table_sym

      extend ClassMethods
      include InstanceMethods::GeneralMethods
    end

    def associations_from_relationships(relationships, table_sym)
      if relationships.include? :sender
        has_many :messages, as: :sender, class_name: 'MessageTrain::Message'
      end

      return unless relationships.include? :recipient

      has_many(
        :receipts,
        as: :recipient,
        class_name: 'MessageTrain::Receipt'
      )
      has_many(
        :unsubscribes,
        as: :recipient,
        class_name: 'MessageTrain::Unsubscribe'
      )

      MessageTrain.configure(MessageTrain.configuration) do |config|
        config.recipient_tables[table_sym] = name
      end
    end

    # Extended when message_train mixin is run
    module ClassMethods
      def self.extended(base)
        base.class_eval do
          scope :where_slug_starts_with, (lambda do |string|
            return where(nil) unless string.present?
            field_name = MessageTrain.configuration.slug_columns[
              message_train_table_sym
            ]
            pattern = Regexp.union('\\', '%', '_')
            string = string.gsub(pattern) { |x| ['\\', x].join }
            where("#{field_name} LIKE ?", "#{string}%")
          end)
        end
      end

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
          conversations = MessageTrain::Conversation.with_messages_through(
            self
          ).without_deleted_for(participant)

          definition_method = BOX_DEFINITIONS[division]
          return if definition_method.nil?
          conversations = conversations.send(definition_method, participant)

          BOX_OMISSION_DEFINITIONS.each do |division_key, omission_method|
            next if division_key == division # Because not to be omitted
            conversations = conversations.send(
              omission_method, participant
            )
          end

          conversations
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
          case args.count
          when 0
            participant = self
          when 1
            participant = args[0] || self
          else # Treat all but the division as a hash of options
            raise :wrong_number_of_arguments_right_wrong.l(
              right: '0..1',
              wrong: args.count.to_s,
              thing: self.class.name
            )
          end
          results = MessageTrain::Conversation.with_messages_through(self)
          if results.empty?
            []
          else
            results.with_messages_for(participant)
          end
        end

        def all_messages(*args)
          case args.count
          when 0
            participant = self
          when 1
            participant = args[0] || self
          else # Treat all but the division as a hash of options
            raise :wrong_number_of_arguments_right_wrong.l(
              right: '0..1',
              wrong: args.count.to_s,
              thing: self.class.name
            )
          end
          results = MessageTrain::Message.with_receipts_through(self)
          if results.empty?
            []
          else
            results.with_receipts_for(participant)
          end
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
          collective_boxes = {}
          unless cb_tables.empty?
            cb_tables.each do |table_symbol, collectives_method|
              collective_boxes[table_symbol] ||= []
              collective_boxes[table_symbol] += table_collective_box(
                table_symbol,
                collectives_method,
                division,
                participant
              )
            end
          end
          collective_boxes
        end

        def table_collective_box(
          table_symbol,
          collectives_method,
          division,
          participant
        )
          class_name = MessageTrain.configuration
                                   .recipient_tables[table_symbol]
          model = class_name.constantize
          collectives = model.send(collectives_method, participant)

          boxes = []
          return boxes if collectives.empty?
          collectives.each do |collective|
            boxes << collective.box(
              division,
              participant
            )
          end
          boxes.compact
        end

        def all_boxes(*args)
          case args.count
          when 0
            participant = self
          when 1
            participant = args[0] || self
          else # Treat all but the division as a hash of options
            raise :wrong_number_of_arguments_right_wrong.l(
              right: '0..1',
              wrong: args.count.to_s,
              thing: self.class.name
            )
          end
          divisions = [:in, :sent, :all, :drafts, :trash, :ignored]
          divisions.collect do |division|
            MessageTrain::Box.new(self, division, participant)
          end
        end

        protected

        def self_subscription
          {
            from: self,
            from_type: self.class.name,
            from_id: id,
            from_name: :messages_directly_to_myself.l,
            unsubscribe: unsubscribes.find_by(from: self)
          }
        end

        def subscription(box)
          parent = box.parent
          parent_class = parent.class
          return unless parent.allows_receiving_by?(self)
          collective_name = parent.send(
            MessageTrain.configuration.name_columns[
              parent_class.table_name.to_sym
            ]
          )
          {
            from: parent,
            from_type: parent_class.name,
            from_id: parent.id,
            from_name: :messages_to_collective.l(
              collective: collective_name
            ),
            unsubscribe: unsubscribes.find_by(from: parent)
          }
        end
      end
    end
  end
end
