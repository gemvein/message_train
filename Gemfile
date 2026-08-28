source 'https://rubygems.org'
# Add dependencies required to use your gem here.
# Example:
gem 'haml-rails', '>= 2'
gem 'rails', '>= 7.1', '< 9'
gem 'rails-i18n', '>= 7', '< 9'
gem 'image_processing', '~> 1.2'
gem 'mini_magick', '~> 4.12'
gem 'benchmark' # mini_magick requires it; no longer a Ruby default gem as of 4.0

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'

gem 'dartsass-rails', '~> 0.5'
gem 'importmap-rails', '~> 2.0'
gem 'kaminari', '~> 1.0'
gem 'propshaft', '~> 1.1'
gem 'redcarpet', '~> 3.6'
gem 'stimulus-rails', '~> 1.3'
gem 'turbo-rails', '~> 2.0'

# Add dependencies to develop your gem here.
# Include everything needed to run rake, tests, features, etc.
group :development do
  gem 'rubocop', '~> 1.6', require: false
  gem 'rubocop-rails', '~> 2.25', require: false
  gem 'rubocop-rake', '~> 0.7', require: false
  gem 'rubocop-rspec', '~> 3.0', require: false
end

group :development, :test do
  gem 'byebug', '~> 11'
  gem 'devise', '~> 4'
  gem 'factory_bot_rails', '~> 6.4'
  gem 'faker', '~> 3'
  gem 'friendly_id', '~> 5'
  gem 'high_voltage', '~> 3'
  gem 'rolify', '>= 4'
  gem 'rspec-its', '>= 1', '< 2'
  gem 'rspec-rails', '~> 7.0'
  gem 'seedbank', '~> 0.3'
  gem 'sqlite3', '~> 2.1'
end

group :test do
  gem 'capybara', '~> 3.40'
  gem 'cuprite', '~> 0.15'
  gem 'database_cleaner-active_record', '~> 2.1'
  gem 'launchy', '~> 2', require: false
  gem 'puma', '~> 6.0'
  gem 'rails-controller-testing', '~> 1.0'
  gem 'rspec-collection_matchers', '>= 1'
  gem 'rspec-html-matchers', '~> 0.10'
  gem 'shoulda-matchers', '~> 6.0'
  gem 'simplecov', '~> 0.22', require: false
end
