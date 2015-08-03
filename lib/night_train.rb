module NightTrain
  require "active_record/railtie"
  require "action_controller/railtie"
  require "action_mailer/railtie"
  require "action_view/railtie"
  require "sprockets/railtie"

  require 'rails-i18n'

  require 'night_train/configuration'
  require 'night_train/engine'
  require 'night_train/localization'
  require 'night_train/version'
  require 'night_train/mixin'

  require 'haml-rails'
  require 'bootstrap_leather'
end

ActiveRecord::Base.send(:include, NightTrain::Mixin)