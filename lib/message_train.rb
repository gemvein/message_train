module MessageTrain
  require "active_record/railtie"
  require "action_controller/railtie"
  require "action_mailer/railtie"
  require "action_view/railtie"
  require "sprockets/railtie"

  require 'rails-i18n'

  require 'message_train/configuration'
  require 'message_train/engine'
  require 'message_train/localization'
  require 'message_train/version'
  require 'message_train/mixin'

  require 'haml-rails'
  require 'bootstrap_leather'
end

ActiveRecord::Base.send(:include, MessageTrain::Mixin)