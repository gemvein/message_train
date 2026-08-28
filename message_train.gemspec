# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'message_train/version'

Gem::Specification.new do |s|
  s.name = 'message_train'
  s.version = MessageTrain::VERSION
  s.required_ruby_version = '>= 3.2'

  s.authors = ['Loren Lundgren']
  s.email = 'loren.lundgren@gmail.com'
  s.summary = 'Rails Engine providing messaging for any object'
  s.description = 'Rails Engine providing private and public messaging '\
                   'for any object, such as Users or Groups'
  s.homepage = 'http://www.gemvein.com/museum/cases/message_train'
  s.license = 'MIT'

  s.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(spec/dummy/db/(development|test)\.sqlite3|\.idea/)})
  end
  s.extra_rdoc_files = %w[LICENSE.txt README.md]
  s.require_paths = ['lib']

  s.add_runtime_dependency 'dartsass-rails', '~> 0.5'
  s.add_runtime_dependency 'haml-rails', '>= 2'
  s.add_runtime_dependency 'image_processing', '~> 1.2'
  s.add_runtime_dependency 'importmap-rails', '~> 2.0'
  s.add_runtime_dependency 'jbuilder', '~> 2.0'
  s.add_runtime_dependency 'kaminari', '~> 1.0'
  s.add_runtime_dependency 'mini_magick', '~> 4.12'
  s.add_runtime_dependency 'propshaft', '~> 1.1'
  s.add_runtime_dependency 'rails', '>= 7.1', '< 9'
  s.add_runtime_dependency 'rails-i18n', '>= 7', '< 9'
  s.add_runtime_dependency 'redcarpet', '~> 3.6'
  s.add_runtime_dependency 'stimulus-rails', '~> 1.3'
  s.add_runtime_dependency 'turbo-rails', '~> 2.0'

  s.add_development_dependency 'byebug', '~> 11'
  s.add_development_dependency 'capybara', '~> 3.40'
  s.add_development_dependency 'cuprite', '~> 0.15'
  s.add_development_dependency 'database_cleaner-active_record', '~> 2.1'
  s.add_development_dependency 'devise', '~> 4'
  s.add_development_dependency 'factory_bot_rails', '~> 6.4'
  s.add_development_dependency 'faker', '~> 3'
  s.add_development_dependency 'friendly_id', '~> 5'
  s.add_development_dependency 'high_voltage', '~> 3'
  s.add_development_dependency 'launchy', '~> 2'
  s.add_development_dependency 'puma', '~> 6.0'
  s.add_development_dependency 'rails-controller-testing', '~> 1.0'
  s.add_development_dependency 'rolify', '>= 4'
  s.add_development_dependency 'rspec-collection_matchers', '>= 1'
  s.add_development_dependency 'rspec-html-matchers', '~> 0.10'
  s.add_development_dependency 'rspec-its', '>= 1', '< 2'
  s.add_development_dependency 'rspec-rails', '~> 7.0'
  s.add_development_dependency 'rubocop', '~> 1.6'
  s.add_development_dependency 'rubocop-rails', '~> 2.25'
  s.add_development_dependency 'rubocop-rake', '~> 0.7'
  s.add_development_dependency 'rubocop-rspec', '~> 3.0'
  s.add_development_dependency 'seedbank', '~> 0.3'
  s.add_development_dependency 'shoulda-matchers', '~> 6.0'
  s.add_development_dependency 'simplecov', '~> 0.22'
  s.add_development_dependency 'sqlite3', '~> 2.1'
end
