module MessageTrain
  # Mixin for including in a model
  module Mixin
    extend ActiveSupport::Concern
    class_methods do
      def message_train(options = {})
        table_sym = table_name.to_sym

        relationships = if options[:only]
                          [options[:only]].flatten
                        else
                          [:sender, :recipient]
                        end
        options[:except] && relationships -= [options[:except]].flatten

        if relationships.include? :sender
          has_many :messages, as: :sender, class_name: 'MessageTrain::Message'
        end

        if relationships.include? :recipient
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
        end

        MessageTrain.configure(MessageTrain.configuration) do |config|
          if options[:name_column].present?
            config.name_columns[table_sym] = options[:name_column]
          end

          if options[:slug_column].present?
            config.slug_columns[table_sym] = options[:slug_column]
          end

          if options[:address_book_method].present?
            config.address_book_methods[table_sym] = options[
              :address_book_method
            ]
          end

          if relationships.include? :recipient
            config.recipient_tables[table_sym] = name
          end

          if options[:collectives_for_recipient].present?
            config.collectives_for_recipient_methods[table_sym] = options[
              :collectives_for_recipient
            ]
          end

          if options[:valid_senders].present?
            config.valid_senders_methods[table_sym] = options[:valid_senders]
          end

          if options[:valid_recipients].present?
            config.valid_recipients_methods[table_sym] = options[
              :valid_recipients
            ]
          end
        end

        send(:define_method, :slug_part) do
          send(MessageTrain.configuration.slug_columns[table_sym] || :slug)
        end

        send(:define_method, :path_part) do
          if MessageTrain.configuration.valid_senders_methods[
            table_sym
          ].present?
            # This must mean it's a collective
            "#{self.class.table_name}:#{slug_part}"
          end
        end

        send(:define_method, :valid_senders) do
          send(
            MessageTrain.configuration.valid_senders_methods[
              self.class.table_name.to_sym
            ] || :self_collection
          )
        end

        send(:define_method, :allows_sending_by?) do |sender|
          valid_senders.include? sender
        end

        send(:define_method, :valid_recipients) do
          send(
            MessageTrain.configuration.valid_recipients_methods[
              self.class.table_name.to_sym
            ] || :self_collection
          )
        end

        send(:define_method, :allows_receiving_by?) do |recipient|
          if valid_recipients.nil? || valid_recipients.empty?
            false
          else
            valid_recipients.include? recipient
          end
        end

        send(:define_method, :self_collection) do
          # This turns a single record into an active record collection.
          model = self.class
          model.where(id: id)
        end

        if relationships.include? :recipient
          send(:define_method, :box) do |*args|
            case args.count
            when 0
              division = :in
              participant = self
            when 1
              division = args[0] || :in
              participant = self
            when 2
              division = args[0] || :in
              participant = args[1] || self
            else
              raise :wrong_number_of_arguments_right_wrong.l(
                right: '0..2',
                wrong: args.count.to_s,
                thing: self.class.name
              )
            end
            @box ||= MessageTrain::Box.new(self, division, participant)
          end

          send(:define_method, :collective_boxes) do |*args|
            case args.count
            when 0
              division = :in
              participant = self
            when 1
              division = args[0] || :in
              participant = self
            when 2
              division = args[0] || :in
              participant = args[1] || self
            else # Treat all but the division as a hash of options
              raise :wrong_number_of_arguments_right_wrong.l(
                right: '0..2',
                wrong: args.count.to_s,
                thing: self.class.name
              )
            end
            cb_tables = MessageTrain.configuration
                                    .collectives_for_recipient_methods
            collective_boxes = {}
            unless cb_tables.empty?
              cb_tables.each do |my_table_symbol, collectives_method|
                class_name = MessageTrain.configuration
                                         .recipient_tables[my_table_symbol]
                model = class_name.constantize
                collectives = model.send(collectives_method, participant)
                next if collectives.empty?
                collectives.each do |collective|
                  collective_boxes[my_table_symbol] ||= []
                  collective_boxes[my_table_symbol] << collective.box(
                    division,
                    participant
                  )
                end
              end
            end
            collective_boxes
          end

          send(:define_method, :all_boxes) do |*args|
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
        end

        send(:define_method, :conversations) do |*args|
          case args.count
          when 0
            division = :in
            participant = self
          when 1
            division = args[0] || :in
            participant = self
          when 2
            division = args[0] || :in
            participant = args[1] || self
          else # Treat all but the division as a hash of options
            raise :wrong_number_of_arguments_right_wrong.l(
              right: '0..2',
              wrong: args.count.to_s,
              thing: self.class.name
            )
          end
          my_conversations = MessageTrain::Conversation.with_messages_through(
            self
          )
          case division
          when :in
            my_conversations.with_untrashed_to(participant)
          when :sent
            my_conversations.with_untrashed_by(participant)
          when :all
            my_conversations.with_untrashed_for(participant)
          when :drafts
            my_conversations.with_drafts_by(participant)
          when :trash
            my_conversations.with_trashed_for(participant)
          when :ignored
            my_conversations.ignored(participant)
          end
        end

        send(:define_method, :boxes_for_participant) do |participant|
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

        send(:define_method, :all_conversations) do |*args|
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

        send(:define_method, :all_messages) do |*args|
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

        send(:define_method, :unsubscribed_from_all?) do
          unsubscribes.where(from: nil).exists?
        end

        send(:define_method, :unsubscribed_from?) do |from|
          unsubscribed_from_all? || unsubscribes.where(from: from).exists?
        end

        send(:define_method, :unsubscribe_from) do |from|
          unsubscribes.find_or_create_by(from: from)
        end

        send(:define_method, :subscriptions) do
          subscriptions = []
          subscriptions << {
            from: self,
            from_type: self.class.name,
            from_id: id,
            from_name: :messages_directly_to_myself.l,
            unsubscribe: unsubscribes.find_by(from: self)
          }
          collective_boxes.values.each do |boxes|
            boxes.each do |box|
              next unless box.parent.allows_receiving_by?(self)
              collective_name = box.parent.send(
                MessageTrain.configuration.name_columns[
                  box.parent.class.table_name.to_sym
                ]
              )
              subscriptions << {
                from: box.parent,
                from_type: box.parent.class.name,
                from_id: box.parent.id,
                from_name: :messages_to_collective.l(
                  collective: collective_name
                ),
                unsubscribe: unsubscribes.find_by(from: box.parent)
              }
            end
          end
          subscriptions
        end
      end
    end
  end
end
