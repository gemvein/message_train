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

        send(:define_method, :conversations) {
          conversation_ids = []
          if relationships.include? :sender
            conversation_ids += messages.collect { |x| x.conversation_id }
          end

          if relationships.include? :recipient
            conversation_ids += receipts.collect { |x| x.message.conversation_id }
          end
          NightTrain::Conversation.where('id IN (?)', conversation_ids)
        }
      end
    end
  end
end