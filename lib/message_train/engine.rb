module MessageTrain
  # MessageTrain Engine
  class Engine < ::Rails::Engine
    isolate_namespace MessageTrain
    config.generators do |g|
      g.hidden_namespaces << :test_unit << :erb << :mongoid
      g.orm             :active_record
      g.template_engine :haml
      g.test_framework  :rspec, fixture: false
      g.stylesheets     false
      g.javascripts     false
    end

    initializer 'message_train.importmap', before: 'importmap' do |app|
      if app.config.respond_to?(:importmap)
        app.config.importmap.paths << Engine.root.join('config/importmap.rb')
        app.config.importmap.cache_sweepers << Engine.root.join('app/javascript')
      end
    end

    initializer 'message_train.assets', before: 'importmap.assets' do |app|
      app.config.assets.paths << Engine.root.join('app/javascript') if app.config.respond_to?(:assets)
    end
  end
end
