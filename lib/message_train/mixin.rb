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
          if options[:friendly_id]
            config.friendly_id_tables << table_sym
          end

          if options[:name_column]
            config.name_columns[table_sym] = options[:name_column]
          else
            config.name_columns[table_sym] = :name
          end

          if relationships.include? :recipient
            config.recipient_tables |= [table_sym] # This adds the table to the array if not present
          end
        end

        send(:define_method, :box) { |*args|
          case args.count
            when 0
              division = :in
            when 1
              division = args[0]
            else
              raise :wrong_number_of_arguments_for_box_expected_right_got_wrong.l(right: '0..1', wrong: args.count.to_s)
          end
          @box ||= MessageTrain::Box.new(self, division)
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