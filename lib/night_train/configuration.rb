module NightTrain
  def self.configure(configuration = NightTrain::Configuration.new)
    if block_given?
      yield configuration
    end
    @@configuration = configuration
  end

  def self.configuration
    @@configuration ||= NightTrain::Configuration.new
  end

  class Configuration
    attr_accessor :friendly_id_tables,
                  :slug_columns,
                  :name_columns,
                  :current_user_method,
                  :user_sign_in_path,
                  :user_route_authentication_method,
                  :address_book_method,
                  :recipient_tables

    def initialize
      self.friendly_id_tables = []
      self.recipient_tables = [ :users ]
      self.slug_columns = { users: :slug }
      self.name_columns = { users: :display_name }
      self.current_user_method = :current_user
      self.user_sign_in_path = '/users/sign_in'
      self.user_route_authentication_method = :user
      self.address_book_method = :address_book
    end

  end
end