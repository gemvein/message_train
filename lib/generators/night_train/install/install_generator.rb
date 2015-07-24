module NightTrain
  class InstallGenerator < Rails::Generators::Base
    source_root File.expand_path("../templates", __FILE__)
    require File.expand_path('../../utils', __FILE__)
    include Generators::Utils
    include Rails::Generators::Migration

    def hello
      output "NightTrain Installer will now install itself", :magenta
    end

    # all public methods in here will be run in order

    def add_initializer
      output "First, you'll need an initializer.  This is where you put your configuration options.", :magenta
      template "initializer.rb", "config/initializers/paid_up.rb"
    end

    def add_migrations
      output "Next come migrations.", :magenta
      rake 'night_train:install:migrations'
    end

    def add_route
      output "Adding NightTrain to your routes.rb file", :magenta
      gsub_file "config/routes.rb", /mount NightTrain::Engine => '\/.*', :as => 'night_train'/, ''
      route("mount NightTrain::Engine => '/messages', :as => 'night_train'")
    end
  end
end