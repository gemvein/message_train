module ActiveRecord
  # rubocop:disable Style/ClassVars
  # Rubocop is wrong about these being needed: they are needed because when
  # changed to class-level instance variables the connection isn't really
  # shared.
  class Base
    mattr_accessor :shared_connection
    @@shared_connection = nil

    def self.connection
      @@shared_connection || retrieve_connection
    end
  end
  # rubocop:enable Style/ClassVars
end

# Forces all threads to share the same connection. This works on
# Capybara because it starts the web server in a thread.
ActiveRecord::Base.shared_connection = ActiveRecord::Base.connection
