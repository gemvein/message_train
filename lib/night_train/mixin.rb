module NightTrain
  module Mixin
    extend ActiveSupport::Concern
    class_methods do
      def night_train(options = {})
        NightTrain.configure(NightTrain.configuration) do |config|
          if options[:friendly_id]
            config.friendly_id_tables << table_name.to_sym
          end

          if options[:name_column]
            config.name_columns[table_name.to_sym] = options[:name_column]
          else
            config.name_columns[table_name.to_sym] = :name
          end
        end

        relationships = options[:only] ? [options[:only]].flatten : [:sender, :recipient]
        if options[:except]
          relationships = relationships - [options[:except]].flatten
        end

        if relationships.include? :sender
          has_many :messages, as: :sender, class_name: 'NightTrain::Message'
        end
        
        if relationships.include? :recipient
          has_many :receipts, as: :recipient, class_name: 'NightTrain::Receipt'
        end

        send(:define_method, :box) { |division|
          @box ||= NightTrain::Box.new(self, division)
        }

        send(:define_method, :conversations) { |division|
          case division
            when :in
              NightTrain::Conversation.with_untrashed_to(self)
            when :sent
              NightTrain::Conversation.with_untrashed_by(self)
            when :all
              NightTrain::Conversation.with_untrashed_for(self)
            when :drafts
              NightTrain::Conversation.with_drafts_by(self)
            when :trash
              NightTrain::Conversation.with_trashed_for(self)
            else
              nil
          end
        }

        send(:define_method, :all_boxes) {
          divisions = [:in, :sent, :all, :drafts, :trash]
          divisions.collect { |division| NightTrain::Box.new(self, division) }
        }

        send(:define_method, :all_conversations) {
          NightTrain::Conversation.with_receipts_for(self)
        }

        send(:define_method, :all_messages) {
          NightTrain::Message.with_receipts_for(self)
        }
      end
    end
  end
end