require_relative 'boot'

require 'rails'
# Pick the frameworks you want:
require 'active_record/railtie'
require 'active_storage/engine'
require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'action_mailbox/engine'
require 'action_text/engine'
require 'action_view/railtie'
# require 'rails/test_unit/railtie'

Bundler.require(*Rails.groups)
require 'message_train'

module Dummy
  class Application < Rails::Application
    config.load_defaults 8.1

    config.generators do |g|
      g.orm             :active_record
      g.template_engine :haml
      g.test_framework  :rspec, fixture: false
      g.stylesheets     false
      g.javascripts     false
    end

    config.time_zone = 'America/Denver'
    config.active_record.default_timezone = :local
    config.active_storage.variant_processor = :mini_magick
  end
end

FactoryBot.definition_file_paths << MessageTrain::Engine.root.join(
  'spec/factories'
)
