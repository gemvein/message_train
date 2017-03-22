module MessageTrain
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
      ] || :slug
      pattern = Regexp.union('\\', '%', '_')
      string = string.gsub(pattern) { |x| ['\\', x].join }
      where("#{field_name} LIKE ?", "#{string}%")
    end

    def slug_column
      MessageTrain.configuration.slug_columns[message_train_table_sym] || :slug
    end

    def name_column
      MessageTrain.configuration.name_columns[message_train_table_sym] || :name
    end

    def valid_senders_method
      MessageTrain.configuration
                  .valid_senders_methods[message_train_table_sym] ||
        :self_collection
    end

    def valid_recipients_method
      MessageTrain.configuration
                  .valid_recipients_methods[message_train_table_sym] ||
        :self_collection
    end

    def collective?
      valid_senders_method != :self_collection
    end
  end
end
