module NightTrain
  class Engine < ::Rails::Engine
    isolate_namespace NightTrain
    config.generators do |g|
      g.hidden_namespaces << :test_unit << :erb << :mongoid
      g.orm             :active_record
      g.template_engine :haml
      g.test_framework  :rspec, fixture: false
      g.stylesheets     false
      g.javascripts     false
    end
  end
end
