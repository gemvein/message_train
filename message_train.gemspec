# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-
# stub: message_train 0.6.17 ruby lib

Gem::Specification.new do |s|
  s.name = "message_train"
  s.version = "0.6.17"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Karen Lundgren"]
  s.date = "2017-03-23"
  s.description = "Rails 4 Engine providing private/public messaging for any object, such as Users or Groups"
  s.email = "karen.e.lundgren@gmail.com"
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.rdoc"
  ]
  s.files = [
    ".document",
    ".rspec",
    ".rubocop.yml",
    ".rubocop_todo.yml",
    ".ruby-gemset",
    ".ruby-version",
    ".scss-lint.yml",
    ".simplecov",
    ".travis.yml",
    "Gemfile",
    "LICENSE.txt",
    "README.rdoc",
    "Rakefile",
    "VERSION",
    "app/assets/javascripts/ckeditor/config.js",
    "app/assets/javascripts/message_train.js",
    "app/assets/stylesheets/message_train.scss",
    "app/controllers/concerns/message_train_authorization_support.rb",
    "app/controllers/concerns/message_train_support.rb",
    "app/controllers/message_train/application_controller.rb",
    "app/controllers/message_train/boxes_controller.rb",
    "app/controllers/message_train/conversations_controller.rb",
    "app/controllers/message_train/messages_controller.rb",
    "app/controllers/message_train/participants_controller.rb",
    "app/controllers/message_train/unsubscribes_controller.rb",
    "app/helpers/message_train/application_helper.rb",
    "app/helpers/message_train/attachments_helper.rb",
    "app/helpers/message_train/boxes_helper.rb",
    "app/helpers/message_train/collectives_helper.rb",
    "app/helpers/message_train/conversations_helper.rb",
    "app/helpers/message_train/messages_helper.rb",
    "app/mailers/message_train/application_mailer.rb",
    "app/mailers/message_train/previews/receipt_mailer_preview.rb",
    "app/mailers/message_train/receipt_mailer.rb",
    "app/models/message_train/attachment.rb",
    "app/models/message_train/box.rb",
    "app/models/message_train/conversation.rb",
    "app/models/message_train/ignore.rb",
    "app/models/message_train/message.rb",
    "app/models/message_train/receipt.rb",
    "app/models/message_train/unsubscribe.rb",
    "app/views/application/404.html.haml",
    "app/views/layouts/mailer.html.haml",
    "app/views/layouts/mailer.text.haml",
    "app/views/message_train/application/_attachment_fields.html.haml",
    "app/views/message_train/application/_attachment_link.html.haml",
    "app/views/message_train/application/_widget.html.haml",
    "app/views/message_train/application/results.json.jbuilder",
    "app/views/message_train/boxes/_dropdown_list.html.haml",
    "app/views/message_train/boxes/_list_item.html.haml",
    "app/views/message_train/boxes/_widget.html.haml",
    "app/views/message_train/boxes/show.html.haml",
    "app/views/message_train/collectives/_dropdown_list.html.haml",
    "app/views/message_train/collectives/_list_item.html.haml",
    "app/views/message_train/collectives/_widget.html.haml",
    "app/views/message_train/conversations/_conversation.html.haml",
    "app/views/message_train/conversations/_deleted_toggle.html.haml",
    "app/views/message_train/conversations/_ignored_toggle.html.haml",
    "app/views/message_train/conversations/_read_toggle.html.haml",
    "app/views/message_train/conversations/_toggle.html.haml",
    "app/views/message_train/conversations/_trashed_toggle.html.haml",
    "app/views/message_train/conversations/show.html.haml",
    "app/views/message_train/conversations/show.json.jbuilder",
    "app/views/message_train/messages/_deleted_toggle.html.haml",
    "app/views/message_train/messages/_form.html.haml",
    "app/views/message_train/messages/_message.html.haml",
    "app/views/message_train/messages/_read_toggle.html.haml",
    "app/views/message_train/messages/_toggle.html.haml",
    "app/views/message_train/messages/_trashed_toggle.html.haml",
    "app/views/message_train/messages/edit.html.haml",
    "app/views/message_train/messages/new.html.haml",
    "app/views/message_train/messages/show.json.jbuilder",
    "app/views/message_train/participants/_participant.json.jbuilder",
    "app/views/message_train/participants/_prefilled_field.html.haml",
    "app/views/message_train/participants/index.json.jbuilder",
    "app/views/message_train/participants/show.json.jbuilder",
    "app/views/message_train/receipt_mailer/notification_email.html.haml",
    "app/views/message_train/receipt_mailer/notification_email.text.haml",
    "app/views/message_train/unsubscribes/index.html.haml",
    "config/environment.rb",
    "config/initializers/bootstrap_pager_config.rb",
    "config/initializers/date_time.rb",
    "config/locales/en.yml",
    "config/routes.rb",
    "db/migrate/20150721145319_create_message_train_conversations.rb",
    "db/migrate/20150721160322_create_message_train_messages.rb",
    "db/migrate/20150721161144_create_message_train_attachments.rb",
    "db/migrate/20150721161940_create_message_train_receipts.rb",
    "db/migrate/20150721163838_create_message_train_ignores.rb",
    "db/migrate/20150901183458_add_received_through_to_message_train_receipts.rb",
    "db/migrate/20151004184347_add_unique_index_to_receipts.rb",
    "db/migrate/20151124000820_create_message_train_unsubscribes.rb",
    "lib/generators/message_train/install/install_generator.rb",
    "lib/generators/message_train/install/templates/initializer.rb",
    "lib/generators/message_train/utils.rb",
    "lib/message_train.rb",
    "lib/message_train/class_methods.rb",
    "lib/message_train/configuration.rb",
    "lib/message_train/engine.rb",
    "lib/message_train/instance_methods.rb",
    "lib/message_train/localization.rb",
    "lib/message_train/mixin.rb",
    "lib/message_train/version.rb",
    "lib/tasks/message_train_tasks.rake",
    "message_train.gemspec",
    "spec/controllers/message_train/boxes_controller_spec.rb",
    "spec/controllers/message_train/concerns_spec.rb",
    "spec/controllers/message_train/conversations_controller_spec.rb",
    "spec/controllers/message_train/messages_controller_spec.rb",
    "spec/controllers/message_train/participants_controller_spec.rb",
    "spec/controllers/message_train/unsubscribes_controller_spec.rb",
    "spec/dummy/.rspec",
    "spec/dummy/Rakefile",
    "spec/dummy/app/assets/files/message_train/attachments/ACD_Silverbarn's_Mayumi.jpg",
    "spec/dummy/app/assets/files/message_train/attachments/ACD_obedience.jpg",
    "spec/dummy/app/assets/files/message_train/attachments/A_Man_and_His_Dog.jpg",
    "spec/dummy/app/assets/files/message_train/attachments/Alaskan_Malamute_agility_a-frame.jpg",
    "spec/dummy/app/assets/files/message_train/attachments/American_water_spaniel_02.jpg",
    "spec/dummy/app/assets/files/message_train/attachments/Aport_konkurs_rybnik.jpg",
    "spec/dummy/app/assets/files/message_train/attachments/Askerhytta.jpg",
    "spec/dummy/app/assets/files/message_train/attachments/Bambisj.jpg",
    "spec/dummy/app/assets/files/message_train/attachments/Cattle_dog_skating.jpg",
    "spec/dummy/app/assets/files/message_train/attachments/Dog's_Olympics_training_ground_-_geograph.org.uk_-_660324.jpg",
    "spec/dummy/app/assets/files/message_train/attachments/DogShowHierarchy.png",
    "spec/dummy/app/assets/files/message_train/attachments/Dog_weight_pull.jpg",
    "spec/dummy/app/assets/files/message_train/attachments/Draghuntpostcard.jpg",
    "spec/dummy/app/assets/files/message_train/attachments/Esham_51.JPG",
    "spec/dummy/app/assets/files/message_train/attachments/FastCourseExample.jpg",
    "spec/dummy/app/assets/files/message_train/attachments/Fotos_joel_141.JPG",
    "spec/dummy/app/assets/files/message_train/attachments/Galgo_Spanish_male_brindle.jpg",
    "spec/dummy/app/assets/files/message_train/attachments/Golden-retriever-carlos-bei-der-dummyarbeit.jpg",
    "spec/dummy/app/assets/files/message_train/attachments/Habavk.jpg",
    "spec/dummy/app/assets/files/message_train/attachments/Hanging_18.jpg",
    "spec/dummy/app/assets/files/message_train/attachments/Hundewa.jpg",
    "spec/dummy/app/assets/files/message_train/attachments/K9ProSports_AttackOnHandler.jpg",
    "spec/dummy/app/assets/files/message_train/attachments/K9ProSports_heel.jpg",
    "spec/dummy/app/assets/files/message_train/attachments/K9Pro_Civil_agitation.JPG",
    "spec/dummy/app/assets/files/message_train/attachments/TrainingSchutzhundRetrieveOverWall.jpg",
    "spec/dummy/app/assets/files/message_train/attachments/example.pdf",
    "spec/dummy/app/assets/files/message_train/attachments/image-sample.jpg",
    "spec/dummy/app/assets/files/message_train/attachments/letterlegal5.doc",
    "spec/dummy/app/assets/files/message_train/attachments/pdf-sample.pdf",
    "spec/dummy/app/assets/files/message_train/attachments/sample.pdf",
    "spec/dummy/app/assets/files/message_train/attachments/tips.doc",
    "spec/dummy/app/assets/files/message_train/attachments/wd-spectools-word-sample-04.doc",
    "spec/dummy/app/assets/images/logo.svg",
    "spec/dummy/app/assets/javascripts/application.js",
    "spec/dummy/app/assets/stylesheets/application.scss",
    "spec/dummy/app/assets/stylesheets/bootstrap-everything.scss",
    "spec/dummy/app/controllers/application_controller.rb",
    "spec/dummy/app/helpers/application_helper.rb",
    "spec/dummy/app/mailers/.keep",
    "spec/dummy/app/models/group.rb",
    "spec/dummy/app/models/role.rb",
    "spec/dummy/app/models/user.rb",
    "spec/dummy/app/views/layouts/_top_navigation.html.haml",
    "spec/dummy/app/views/layouts/application.html.haml",
    "spec/dummy/app/views/pages/index.html.haml",
    "spec/dummy/bin/bundle",
    "spec/dummy/bin/rails",
    "spec/dummy/bin/rake",
    "spec/dummy/bin/setup",
    "spec/dummy/config.ru",
    "spec/dummy/config/application.rb",
    "spec/dummy/config/boot.rb",
    "spec/dummy/config/database.yml",
    "spec/dummy/config/environment.rb",
    "spec/dummy/config/environments/development.rb",
    "spec/dummy/config/environments/production.rb",
    "spec/dummy/config/environments/test.rb",
    "spec/dummy/config/initializers/assets.rb",
    "spec/dummy/config/initializers/backtrace_silencers.rb",
    "spec/dummy/config/initializers/bootstrap_leather.rb",
    "spec/dummy/config/initializers/cookies_serializer.rb",
    "spec/dummy/config/initializers/devise.rb",
    "spec/dummy/config/initializers/filter_parameter_logging.rb",
    "spec/dummy/config/initializers/high_voltage.rb",
    "spec/dummy/config/initializers/inflections.rb",
    "spec/dummy/config/initializers/message_train.rb",
    "spec/dummy/config/initializers/mime_types.rb",
    "spec/dummy/config/initializers/paperclip.rb",
    "spec/dummy/config/initializers/rolify.rb",
    "spec/dummy/config/initializers/session_store.rb",
    "spec/dummy/config/initializers/wrap_parameters.rb",
    "spec/dummy/config/locales/devise.en.yml",
    "spec/dummy/config/locales/en.yml",
    "spec/dummy/config/routes.rb",
    "spec/dummy/config/secrets.yml",
    "spec/dummy/config/settings.yml",
    "spec/dummy/db/migrate/20150721140013_devise_create_users.rb",
    "spec/dummy/db/migrate/20150721141009_rolify_create_roles.rb",
    "spec/dummy/db/migrate/20150721141128_create_groups.rb",
    "spec/dummy/db/migrate/20150721150307_add_display_name_column_to_users.rb",
    "spec/dummy/db/migrate/20160207190402_create_message_train_conversations.message_train.rb",
    "spec/dummy/db/migrate/20160207190403_create_message_train_messages.message_train.rb",
    "spec/dummy/db/migrate/20160207190404_create_message_train_attachments.message_train.rb",
    "spec/dummy/db/migrate/20160207190405_create_message_train_receipts.message_train.rb",
    "spec/dummy/db/migrate/20160207190406_create_message_train_ignores.message_train.rb",
    "spec/dummy/db/migrate/20160207190407_add_received_through_to_message_train_receipts.message_train.rb",
    "spec/dummy/db/migrate/20160207190408_add_unique_index_to_receipts.message_train.rb",
    "spec/dummy/db/migrate/20160207190409_create_message_train_unsubscribes.message_train.rb",
    "spec/dummy/db/schema.rb",
    "spec/dummy/db/seeds.rb",
    "spec/dummy/db/seeds/conversations.seeds.rb",
    "spec/dummy/db/seeds/development/conversations.seeds.rb",
    "spec/dummy/db/seeds/groups.seeds.rb",
    "spec/dummy/db/seeds/test/attachments.seeds.rb",
    "spec/dummy/db/seeds/test/conversations.seeds.rb",
    "spec/dummy/db/seeds/unsubscribes.seeds.rb",
    "spec/dummy/db/seeds/users.seeds.rb",
    "spec/dummy/db/test.sqlite3",
    "spec/dummy/lib/assets/.keep",
    "spec/dummy/public/404.html",
    "spec/dummy/public/422.html",
    "spec/dummy/public/500.html",
    "spec/dummy/public/favicon.ico",
    "spec/factories/attachment.rb",
    "spec/factories/group.rb",
    "spec/factories/message.rb",
    "spec/factories/user.rb",
    "spec/features/boxes_spec.rb",
    "spec/features/conversations_spec.rb",
    "spec/features/messages_spec.rb",
    "spec/features/unsubscribes_spec.rb",
    "spec/helpers/message_train/application_helper_spec.rb",
    "spec/helpers/message_train/attachment_helper_spec.rb",
    "spec/helpers/message_train/boxes_helper_spec.rb",
    "spec/helpers/message_train/collectives_helper_spec.rb",
    "spec/helpers/message_train/conversations_helper_spec.rb",
    "spec/helpers/message_train/messages_helper_spec.rb",
    "spec/message_train_spec.rb",
    "spec/models/group_spec.rb",
    "spec/models/message_train/attachment_spec.rb",
    "spec/models/message_train/box_spec.rb",
    "spec/models/message_train/conversation_spec.rb",
    "spec/models/message_train/ignore_spec.rb",
    "spec/models/message_train/message_spec.rb",
    "spec/models/message_train/receipt_spec.rb",
    "spec/models/message_train/unsubscribe_spec.rb",
    "spec/models/role_spec.rb",
    "spec/models/user_spec.rb",
    "spec/rails_helper.rb",
    "spec/spec_helper.rb",
    "spec/support/controller_behaviors.rb",
    "spec/support/controller_macros.rb",
    "spec/support/factory_girl.rb",
    "spec/support/feature_behaviors.rb",
    "spec/support/loaded_site/attachments.rb",
    "spec/support/loaded_site/conversations.rb",
    "spec/support/loaded_site/groups.rb",
    "spec/support/loaded_site/loaded_site.rb",
    "spec/support/loaded_site/messages.rb",
    "spec/support/loaded_site/roles.rb",
    "spec/support/loaded_site/users.rb",
    "spec/support/shared_connection.rb",
    "spec/support/utilities.rb"
  ]
  s.homepage = "http://www.gemvein.com/museum/cases/message_train"
  s.licenses = ["MIT"]
  s.rubygems_version = "2.4.5.1"
  s.summary = "Rails 4 Engine providing messaging for any object"

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<haml-rails>, ["~> 0.9"])
      s.add_runtime_dependency(%q<jquery-rails>, ["~> 4"])
      s.add_runtime_dependency(%q<paperclip>, ["< 6", ">= 4.2"])
      s.add_runtime_dependency(%q<rails>, ["~> 5"])
      s.add_runtime_dependency(%q<rails-i18n>, ["< 6", ">= 4"])
      s.add_runtime_dependency(%q<uglifier>, ["< 3.2", ">= 2.7"])
      s.add_runtime_dependency(%q<jbuilder>, ["~> 2.0"])
      s.add_runtime_dependency(%q<bootstrap-sass>, ["~> 3.3"])
      s.add_runtime_dependency(%q<bootstrap_form>, ["~> 2.3"])
      s.add_runtime_dependency(%q<bootstrap_leather>, ["~> 0.9"])
      s.add_runtime_dependency(%q<bootstrap_pager>, ["~> 0.10"])
      s.add_runtime_dependency(%q<bootstrap_tokenfield_rails>, ["~> 0.12"])
      s.add_runtime_dependency(%q<ckeditor>, [">= 0"])
      s.add_runtime_dependency(%q<cocoon>, ["~> 1.2"])
      s.add_runtime_dependency(%q<jquery-ui-bootstrap-rails>, [">= 0"])
      s.add_runtime_dependency(%q<sass-rails>, ["~> 5"])
      s.add_runtime_dependency(%q<twitter-typeahead-rails>, [">= 0"])
      s.add_development_dependency(%q<bundler>, ["~> 1.0"])
      s.add_development_dependency(%q<jeweler>, ["~> 2.0"])
      s.add_development_dependency(%q<pre-commit>, ["~> 0.27"])
      s.add_development_dependency(%q<rubocop>, ["~> 0.47.1"])
      s.add_development_dependency(%q<scss_lint>, ["~> 0.52"])
      s.add_development_dependency(%q<sdoc>, ["~> 0.4.1"])
      s.add_development_dependency(%q<byebug>, ["~> 9"])
      s.add_development_dependency(%q<devise>, ["~> 4"])
      s.add_development_dependency(%q<factory_girl_rails>, ["~> 4.5"])
      s.add_development_dependency(%q<faker>, ["~> 1.4"])
      s.add_development_dependency(%q<friendly_id>, ["~> 5"])
      s.add_development_dependency(%q<high_voltage>, ["~> 3"])
      s.add_development_dependency(%q<rolify>, ["< 5.2", ">= 4"])
      s.add_development_dependency(%q<rspec-its>, ["~> 1.2"])
      s.add_development_dependency(%q<rspec-rails>, ["~> 3.2"])
      s.add_development_dependency(%q<seedbank>, ["~> 0.3"])
      s.add_development_dependency(%q<sqlite3>, ["~> 1.3"])
    else
      s.add_dependency(%q<haml-rails>, ["~> 0.9"])
      s.add_dependency(%q<jquery-rails>, ["~> 4"])
      s.add_dependency(%q<paperclip>, ["< 6", ">= 4.2"])
      s.add_dependency(%q<rails>, ["~> 5"])
      s.add_dependency(%q<rails-i18n>, ["< 6", ">= 4"])
      s.add_dependency(%q<uglifier>, ["< 3.2", ">= 2.7"])
      s.add_dependency(%q<jbuilder>, ["~> 2.0"])
      s.add_dependency(%q<bootstrap-sass>, ["~> 3.3"])
      s.add_dependency(%q<bootstrap_form>, ["~> 2.3"])
      s.add_dependency(%q<bootstrap_leather>, ["~> 0.9"])
      s.add_dependency(%q<bootstrap_pager>, ["~> 0.10"])
      s.add_dependency(%q<bootstrap_tokenfield_rails>, ["~> 0.12"])
      s.add_dependency(%q<ckeditor>, [">= 0"])
      s.add_dependency(%q<cocoon>, ["~> 1.2"])
      s.add_dependency(%q<jquery-ui-bootstrap-rails>, [">= 0"])
      s.add_dependency(%q<sass-rails>, ["~> 5"])
      s.add_dependency(%q<twitter-typeahead-rails>, [">= 0"])
      s.add_dependency(%q<bundler>, ["~> 1.0"])
      s.add_dependency(%q<jeweler>, ["~> 2.0"])
      s.add_dependency(%q<pre-commit>, ["~> 0.27"])
      s.add_dependency(%q<rubocop>, ["~> 0.47.1"])
      s.add_dependency(%q<scss_lint>, ["~> 0.52"])
      s.add_dependency(%q<sdoc>, ["~> 0.4.1"])
      s.add_dependency(%q<byebug>, ["~> 9"])
      s.add_dependency(%q<devise>, ["~> 4"])
      s.add_dependency(%q<factory_girl_rails>, ["~> 4.5"])
      s.add_dependency(%q<faker>, ["~> 1.4"])
      s.add_dependency(%q<friendly_id>, ["~> 5"])
      s.add_dependency(%q<high_voltage>, ["~> 3"])
      s.add_dependency(%q<rolify>, ["< 5.2", ">= 4"])
      s.add_dependency(%q<rspec-its>, ["~> 1.2"])
      s.add_dependency(%q<rspec-rails>, ["~> 3.2"])
      s.add_dependency(%q<seedbank>, ["~> 0.3"])
      s.add_dependency(%q<sqlite3>, ["~> 1.3"])
    end
  else
    s.add_dependency(%q<haml-rails>, ["~> 0.9"])
    s.add_dependency(%q<jquery-rails>, ["~> 4"])
    s.add_dependency(%q<paperclip>, ["< 6", ">= 4.2"])
    s.add_dependency(%q<rails>, ["~> 5"])
    s.add_dependency(%q<rails-i18n>, ["< 6", ">= 4"])
    s.add_dependency(%q<uglifier>, ["< 3.2", ">= 2.7"])
    s.add_dependency(%q<jbuilder>, ["~> 2.0"])
    s.add_dependency(%q<bootstrap-sass>, ["~> 3.3"])
    s.add_dependency(%q<bootstrap_form>, ["~> 2.3"])
    s.add_dependency(%q<bootstrap_leather>, ["~> 0.9"])
    s.add_dependency(%q<bootstrap_pager>, ["~> 0.10"])
    s.add_dependency(%q<bootstrap_tokenfield_rails>, ["~> 0.12"])
    s.add_dependency(%q<ckeditor>, [">= 0"])
    s.add_dependency(%q<cocoon>, ["~> 1.2"])
    s.add_dependency(%q<jquery-ui-bootstrap-rails>, [">= 0"])
    s.add_dependency(%q<sass-rails>, ["~> 5"])
    s.add_dependency(%q<twitter-typeahead-rails>, [">= 0"])
    s.add_dependency(%q<bundler>, ["~> 1.0"])
    s.add_dependency(%q<jeweler>, ["~> 2.0"])
    s.add_dependency(%q<pre-commit>, ["~> 0.27"])
    s.add_dependency(%q<rubocop>, ["~> 0.47.1"])
    s.add_dependency(%q<scss_lint>, ["~> 0.52"])
    s.add_dependency(%q<sdoc>, ["~> 0.4.1"])
    s.add_dependency(%q<byebug>, ["~> 9"])
    s.add_dependency(%q<devise>, ["~> 4"])
    s.add_dependency(%q<factory_girl_rails>, ["~> 4.5"])
    s.add_dependency(%q<faker>, ["~> 1.4"])
    s.add_dependency(%q<friendly_id>, ["~> 5"])
    s.add_dependency(%q<high_voltage>, ["~> 3"])
    s.add_dependency(%q<rolify>, ["< 5.2", ">= 4"])
    s.add_dependency(%q<rspec-its>, ["~> 1.2"])
    s.add_dependency(%q<rspec-rails>, ["~> 3.2"])
    s.add_dependency(%q<seedbank>, ["~> 0.3"])
    s.add_dependency(%q<sqlite3>, ["~> 1.3"])
  end
end

