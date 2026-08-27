Rails.application.configure do
  # Settings specified here will take precedence over those in
  # config/application.rb.

  # Make code changes take effect immediately without server restart.
  config.enable_reloading = true

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true

  # Enable/disable Action Controller caching. By default Action Controller caching is disabled.
  config.action_controller.perform_caching = false

  # Change to :null_store to avoid any caching.
  config.cache_store = :memory_store

  # Store uploaded files on the local file system (see config/storage.yml for options).
  config.active_storage.service = :local

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false
  config.action_mailer.default_url_options = { host: 'localhost:3000' }

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Raises error for missing translations
  # config.i18n.raise_on_missing_translations = true

  config.secret_key_base = 'ac4907450d833ae9cdd320e25bdeedbf3ecb2617dd15e6' \
                            '28bd9704882a26eb298f6cc0d5a11543d287de47f39c60' \
                            'c47e81290600189fe72205f34e84143260c9'
end
