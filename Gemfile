source "http://rubygems.org"
# Add dependencies required to use your gem here.
# Example:
#   gem "activesupport", ">= 2.3.5"
gem 'rails', '~> 4'
gem 'haml', '~> 4'

# Add dependencies to develop your gem here.
# Include everything needed to run rake, tests, features, etc.
group :development do
  gem "rdoc", "~> 3.12"
  gem "bundler", "~> 1.0"
  gem "jeweler", "~> 2.0.1"
end

group :development, :test do
  gem 'sqlite3', '~> 1.3'
  gem 'devise', '~> 3.5'
  gem 'rolify', '~> 4'
  gem 'forgery', '~> 0.6'
  gem 'rspec-rails', '~> 3.2'
  gem 'factory_girl_rails', '~> 4.5'
  gem 'seedbank', '~> 0.3'
end

group :test do
  gem 'capybara', '~> 2.4'
  gem 'database_cleaner', '~> 1.4'
  gem 'rspec-collection_matchers', '~> 1.1'
  gem 'shoulda-matchers', '~> 2.8'
  gem "launchy", "~> 2.1.2", require: false
  gem 'coveralls', '~> 0.8', require: false
end