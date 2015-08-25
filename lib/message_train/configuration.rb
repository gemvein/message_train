module MessageTrain
  def self.configure(configuration = MessageTrain::Configuration.new)
    if block_given?
      yield configuration
    end
    @@configuration = configuration
  end

  def self.configuration
    @@configuration ||= MessageTrain::Configuration.new
  end

  class Configuration
    attr_accessor :slug_columns,
                  :name_columns,
                  :current_user_method,
                  :user_sign_in_path,
                  :user_route_authentication_method,
                  :address_book_method,
                  :address_book_methods,
                  :recipient_tables

    def initialize
      self.recipient_tables = {}
      self.slug_columns = { users: :slug }
      self.name_columns = { users: :name }
      self.current_user_method = :current_user
      self.user_sign_in_path = '/users/sign_in'
      self.user_route_authentication_method = :user
      self.address_book_method = :address_book # This is a fallback
      self.address_book_methods = {}
    end

  end
end