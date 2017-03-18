# MessageTrain module
module MessageTrain
  # @conversions[:mixin_option] = :configuration_name
  @conversions = {}
  @conversions[:slug_column] = :slug_columns
  @conversions[:name_column] = :name_columns
  @conversions[:collectives_for_recipient] = :collectives_for_recipient_methods
  @conversions[:valid_recipients] = :valid_recipients_methods
  @conversions[:valid_senders] = :valid_senders_methods
  @conversions[:address_book_method] = :address_book_methods

  def self.configure(configuration = MessageTrain::Configuration.new)
    yield(configuration) if block_given?
    @configuration = configuration
  end

  def self.configuration
    @configuration ||= MessageTrain::Configuration.new
  end

  def self.configure_table(table_sym, options)
    configure(@configuration) do |config|
      @conversions.each do |mixin_option_sym, configuration_name_sym|
        value = options[mixin_option_sym]
        next unless value.present?
        setting = config.send(configuration_name_sym)
        setting[table_sym] = value
        config.send("#{configuration_name_sym}=", setting)
      end
    end
  end

  # MessageTrain configuration
  class Configuration
    attr_accessor :slug_columns,
                  :name_columns,
                  :current_user_method,
                  :user_model,
                  :user_sign_in_path,
                  :user_route_authentication_method,
                  :address_book_method,
                  :address_book_methods,
                  :recipient_tables,
                  :collectives_for_recipient_methods,
                  :valid_senders_methods,
                  :valid_recipients_methods,
                  :from_email,
                  :site_name

    def initialize
      self.recipient_tables = {}
      self.slug_columns = { users: :slug }
      self.name_columns = { users: :name }
      self.user_model = 'User'
      self.current_user_method = :current_user
      self.user_sign_in_path = '/users/sign_in'
      self.user_route_authentication_method = :user
      self.address_book_method = :address_book # This is a fallback
      self.address_book_methods = {}
      self.collectives_for_recipient_methods = {}
      self.valid_senders_methods = {}
      self.valid_recipients_methods = {}
      self.from_email = ''
      self.site_name = 'Example Site Name'
    end
  end
end
