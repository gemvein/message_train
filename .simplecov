require 'simplecov'
require 'coveralls'

SimpleCov.formatter = Coveralls::SimpleCov::Formatter
SimpleCov.start do
   add_filter 'lib/message_train/localization.rb'
   add_filter 'spec/support'
   add_filter 'spec/dummy'
   add_filter 'spec/factories'
end