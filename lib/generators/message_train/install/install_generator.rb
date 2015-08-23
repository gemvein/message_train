module MessageTrain
  class InstallGenerator < Rails::Generators::Base
    source_root File.expand_path("../templates", __FILE__)
    require File.expand_path('../../utils', __FILE__)
    include Generators::Utils
    include Rails::Generators::Migration

    def hello
      output "MessageTrain Installer will now install itself", :magenta
    end

    # all public methods in here will be run in order

    def add_initializer
      output "First, you'll need an initializer.  This is where you put your configuration options.", :magenta
      template "initializer.rb", "config/initializers/message_train.rb"
    end

    def add_migrations
      output "Next come migrations.", :magenta
      rake 'message_train:install:migrations'
    end

    def add_route
      output "Adding MessageTrain to your routes.rb file", :magenta
      gsub_file "config/routes.rb", /authenticated :[a-z_0-9]+ do\s+mount MessageTrain::Engine => '\/.*', :as => 'message_train'\s+end/, ''
      route("authenticated :user do\n\t\tmount MessageTrain::Engine => '/', :as => 'message_train'\n\tend")
    end
  end
end