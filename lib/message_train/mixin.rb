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
        end

        send(:define_method, :box) { |*args|
          case args.count
            when 0
              division = :in
              options = {}
            when 1
              division = args[0]
              options = {}
            else # Treat all but the division as a hash of options
              division = args.delete_at(0)
              options = args
          end
          @box ||= MessageTrain::Box.new(self, division, options)
        }

        send(:define_method, :conversations) { |division|
          case division
            when :in
              MessageTrain::Conversation.with_untrashed_to(self)
            when :sent
              MessageTrain::Conversation.with_untrashed_by(self)
            when :all
              MessageTrain::Conversation.with_untrashed_for(self)
            when :drafts
              MessageTrain::Conversation.with_drafts_by(self)
            when :trash
              MessageTrain::Conversation.with_trashed_for(self)
            when :ignored
              MessageTrain::Conversation.ignored(self)
            else
              nil
          end
        }

        send(:define_method, :all_boxes) {
          divisions = [:in, :sent, :all, :drafts, :trash, :ignored]
          divisions.collect { |division| MessageTrain::Box.new(self, division) }
        }

        send(:define_method, :all_conversations) {
          MessageTrain::Conversation.with_receipts_for(self)
        }

        send(:define_method, :all_messages) {
          MessageTrain::Message.with_receipts_for(self)
        }
      end
    end
  end
end