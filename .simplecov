require 'simplecov'

SimpleCov.start do
  add_filter 'lib/message_train/localization.rb'
  add_filter '/spec/'
end
