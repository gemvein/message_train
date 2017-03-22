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

      extend MessageTrain::ClassMethods
      include MessageTrain::InstanceMethods
    end

    private

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
  end
end
