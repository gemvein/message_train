module MessageTrain
  module Mixin
    extend ActiveSupport::Concern
    class_methods do
      def message_train(options = {})
        table_sym = table_name.to_sym

        relationships = options[:only] ? [options[:only]].flatten : [:sender, :recipient]
        if options[:except]
          relationships = relationships - [options[:except]].flatten
        end

        if relationships.include? :sender
          has_many :messages, as: :sender, class_name: 'MessageTrain::Message'
        end

        if relationships.include? :recipient
          has_many :receipts, as: :recipient, class_name: 'MessageTrain::Receipt'
        end

        MessageTrain.configure(MessageTrain.configuration) do |config|
          if options[:name_column].present?
            config.name_columns[table_sym] = options[:name_column]
          end

          if options[:slug_column].present?
            config.slug_columns[table_sym] = options[:slug_column]
          end

          if options[:address_book_method].present?
            config.address_book_methods[table_sym] = options[:address_book_method]
          end

          if relationships.include? :recipient
            config.recipient_tables[table_sym] = name
          end

          if options[:collectives_for_recipient].present?
            config.collectives_for_recipient_methods[table_sym] = options[:collectives_for_recipient]
          end

          if options[:valid_senders].present?
            config.valid_senders_methods[table_sym] = options[:valid_senders]
          end

          if options[:valid_recipients].present?
            config.valid_recipients_methods[table_sym] = options[:valid_recipients]
          end
        end

        send(:define_method, :slug_part) {
          send(MessageTrain.configuration.slug_columns[table_sym])
        }

        send(:define_method, :path_part) {
          if MessageTrain.configuration.valid_senders_methods[table_sym].present?
            # This must mean it's a collective
            "#{self.class.table_name}:#{slug_part}"
          end
        }

        send(:define_method, :valid_senders) {
          valid_senders_method = MessageTrain.configuration.valid_senders_methods[self.class.table_name.to_sym] || :self_collection
          send(valid_senders_method)
        }

        send(:define_method, :allows_sending_by?) { |sender|
          valid_senders.include? sender
        }

        send(:define_method, :valid_recipients) {
          valid_recipients_method = MessageTrain.configuration.valid_recipients_methods[self.class.table_name.to_sym] || :self_collection
          send(valid_recipients_method)
        }

        send(:define_method, :allows_receiving_by?) { |recipient|
          if valid_recipients.nil? or valid_recipients.empty?
            false
          else
            valid_recipients.include? recipient
          end
        }

        send(:define_method, :self_collection) { # This turns a single record into an active record collection.
          model = self.class
          model.where(id: self.id)
        }

        if relationships.include? :recipient
          send(:define_method, :box) { |*args|
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
                raise :wrong_number_of_arguments_for_thing_expected_right_got_wrong.l(right: '0..2', wrong: args.count.to_s, thing: self.class.name)
            end
            @box ||= MessageTrain::Box.new(self, division, participant)
          }

          send(:define_method, :collective_boxes) { |*args|
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
                raise :wrong_number_of_arguments_for_thing_expected_right_got_wrong.l(right: '0..2', wrong: args.count.to_s, thing: self.class.name)
            end
            collective_box_tables = MessageTrain.configuration.collectives_for_recipient_methods
            collective_boxes = {}
            unless collective_box_tables.empty?
              collective_box_tables.each do |table_sym, collectives_method|
                class_name = MessageTrain.configuration.recipient_tables[table_sym]
                model = class_name.constantize
                collectives = model.send(collectives_method, @box_user)
                unless collectives.empty?
                  collectives.each do |collective|
                    collective_boxes[table_sym] ||= []
                    collective_boxes[table_sym] << collective.box(division, participant)
                  end
                end
              end
            end
            collective_boxes
          }

          send(:define_method, :all_boxes) { |*args|
            case args.count
              when 0
                participant = self
              when 1
                participant = args[0] || self
              else # Treat all but the division as a hash of options
                raise :wrong_number_of_arguments_for_thing_expected_right_got_wrong.l(right: '0..1', wrong: args.count.to_s, thing: self.class.name)
            end
            divisions = [:in, :sent, :all, :drafts, :trash, :ignored]
            divisions.collect { |division| MessageTrain::Box.new(self, division, participant) }
          }
        end

        send(:define_method, :conversations) { |*args|
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
              raise :wrong_number_of_arguments_for_thing_expected_right_got_wrong.l(right: '0..2', wrong: args.count.to_s, thing: self.class.name)
          end
          my_conversations = MessageTrain::Conversation.with_messages_through(self)
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
            else
              nil
          end
        }

        send(:define_method, :boxes_for_participant) { |participant|
          original_order = [:in, :sent, :all, :drafts, :trash, :ignored]
          divisions = [:all, :trash]
          if self.respond_to?(:messages) || allows_sending_by?(participant)
            divisions += [:sent, :drafts]
          end
          if allows_receiving_by?(participant)
            divisions += [:in, :ignored]
          end
          divisions.sort_by! { |x| original_order.index x }
          divisions.collect { |division| MessageTrain::Box.new(self, division, participant) }
        }

        send(:define_method, :all_conversations) { |*args|
          case args.count
            when 0
              participant = self
            when 1
              participant = args[0] || self
            else # Treat all but the division as a hash of options
              raise :wrong_number_of_arguments_for_thing_expected_right_got_wrong.l(right: '0..1', wrong: args.count.to_s, thing: self.class.name)
          end
          results = MessageTrain::Conversation.with_messages_through(self)
          if results.empty?
            []
          else
            results.with_messages_for(participant)
          end
        }

        send(:define_method, :all_messages) { |*args|
          case args.count
            when 0
              participant = self
            when 1
              participant = args[0] || self
            else # Treat all but the division as a hash of options
              raise :wrong_number_of_arguments_for_thing_expected_right_got_wrong.l(right: '0..1', wrong: args.count.to_s, thing: self.class.name)
          end
          results = MessageTrain::Message.with_receipts_through(self)
          if results.empty?
            []
          else
            results.with_receipts_for(participant)
          end
        }
      end
    end
  end
end