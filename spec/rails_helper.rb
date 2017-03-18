require 'coveralls'
Coveralls.wear!

# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../dummy/config/environment', __FILE__)
# Prevent database truncation if the environment is production
Rails.env.production? && abort(
  'The Rails environment is running in production mode!'
)
require 'spec_helper'
require 'rspec/rails'
# Add additional requires below this line. Rails is not loaded until this point!
require 'shoulda/matchers'
require 'factory_girl_rails'
require 'paperclip/matchers'
require 'capybara/rspec'
require 'capybara/poltergeist'
require 'database_cleaner'
require 'rake'

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
#
Dir[MessageTrain::Engine.root.join('spec/support/*.rb')]
  .each { |f| require f }
Dir[MessageTrain::Engine.root.join('spec/support/**/*.rb')]
  .each { |f| require f }

# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migrator.migrations_paths = 'spec/dummy/db/migrate'
ActiveRecord::Migration.maintain_test_schema!

Capybara.javascript_driver = :poltergeist
# This block needs to be as long as it is.
RSpec.configure do |config|
  config.use_transactional_fixtures = false

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
    Dummy::Application.load_tasks
    Rake::Task['db:seed'].invoke # loading seeds
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, type: :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!

  config.expect_with(:rspec) { |c| c.syntax = [:should, :expect] }
  config.mock_with(:rspec) { |c| c.syntax = [:should, :expect] }

  config.before(:each) { @routes = MessageTrain::Engine.routes }
  config.include MessageTrain::Engine.routes.url_helpers

  config.include Warden::Test::Helpers
  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include Devise::Test::ControllerHelpers, type: :helper
  config.include Devise::Test::ControllerHelpers, type: :routing
  config.include RSpecHtmlMatchers

  # config.include(Shoulda::Matchers::ActiveRecord, type: :model)
  config.include Paperclip::Shoulda::Matchers
  config.after(:suite) do
    FileUtils.rm_rf(Dir["#{Rails.root}/public/system/test/*/*"])
  end
end
# rubocop:enable Metrics/BlockLength

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end
