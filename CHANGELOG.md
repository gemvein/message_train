# Changelog

## 1.0.0

**Breaking change.** This is a from-the-ground-up modernization: Rails
4/5 support is dropped in favor of Rails >= 7.1, < 9, and several
dependencies that no longer exist or no longer matter are removed.
There is no automated migration path from a 0.7.x installation with
real data — see "Upgrading to 1.0.0" in the README before adopting this
version.

### Breaking

- **Ruby >= 3.2, Rails >= 7.1, < 9** required (was Rails 4/5).
- **Paperclip replaced with ActiveStorage.** `MessageTrain::Attachment`
  now uses `has_one_attached :attachment` with named `:thumb`/`:large`
  variants instead of Paperclip styles. Host apps must run
  `bin/rails active_storage:install` (if not already using
  ActiveStorage) and `bin/rails db:migrate` before upgrading. **There is
  no backfill for existing Paperclip-stored files** - this version
  assumes a fresh attachments table. If you have production attachment
  data on 0.7.x, either stay on 0.7.x or write your own backfill before
  upgrading (walk `public/system/...`, attach each file via
  `ActiveStorage::Attached::One#attach`, then run the paperclip-column
  removal migration).
- **CKEditor replaced with Action Text.** `Message#body` is now
  `has_rich_text :body`. Host apps must run
  `bin/rails action_text:install` and `bin/rails db:migrate`.
- **Bootstrap and jQuery removed entirely** - not just the app-specific
  vendor JS (cocoon, typeahead, tokenfield), but `bootstrap-sass`,
  `bootstrap_form`, `bootstrap_leather`, and `jquery-rails` themselves.
  Views are now semantic HTML styled by `message_train.scss` (still a
  real stylesheet, now vanilla CSS) with Turbo Frames and hand-written
  Stimulus controllers. If your host app's layout/theme assumed
  MessageTrain's views were Bootstrap markup, expect visual changes.
- **`importmap-rails`, `turbo-rails`, `stimulus-rails` are now runtime
  dependencies.** The engine ships its own Stimulus controllers and
  registers its own importmap pins and asset paths automatically via an
  engine initializer - no manual pin-in wiring needed in the host app,
  but the host app does need those three gems' own install generators
  already run (i.e. be a normal Hotwire-based Rails 7+ app).
- **Propshaft/`dartsass-rails` replace Sprockets.** If your host app is
  still on Sprockets, either migrate it to Propshaft or vendor
  `message_train.scss` yourself.
- Dead `'Fixnum'` keys in `Box::MARK_METHODS` and
  `Ignore::(UN)IGNORE_METHODS` fixed to `'Integer'` - these had been
  silently no-oping since Ruby 2.4 on any installation using bare
  integer IDs to mark/ignore.

### Fixed

- `Message#create_conversation_if_blank` now runs `before_validation`
  instead of `before_create`, fixing conversation-presence validation
  under Rails 5+'s default-required `belongs_to`.
- `Role#resource`, `Unsubscribe#from`, `Receipt#received_through` marked
  `optional: true` where they're intentionally nullable (global roles,
  unsubscribe-from-everything, direct receipts), matching Rails 5+'s
  default-required `belongs_to`.
- `Receipt.mark`/`Message.mark` now bulk-update instead of looping a
  per-row save, while still touching the affected messages/conversations
  so inbox ordering and fragment-cache keys (which depend on
  `Conversation#updated_at` bumping on mark) keep working.
- Several N+1 query sites addressed: box/conversation listing now
  preloads what its views actually walk per row, `Box#unread_count` and
  `collective_boxes` are memoized per-instance, and
  `Conversation#participant_ignored?` filters in-memory instead of
  querying on every call. (`Conversation#includes_*_for?`'s receipt-flag
  N+1 is a known, documented remaining case - see the comment at
  `Conversation#includes_matching_receipts?`.)
- New indexes on `message_train_receipts.marked_read/marked_trash/
  marked_deleted`, `message_train_conversations.updated_at`, and
  `message_train_messages.draft`.

### Tooling (shouldn't affect host apps)

- Juwelier replaced with a hand-written gemspec; `Rakefile` no longer
  depends on it.
- Travis CI replaced with GitHub Actions.
- factory_girl -> factory_bot, poltergeist -> Cuprite, coveralls dropped,
  `should` -> `expect` syntax throughout the spec suite, rubocop bumped
  with rubocop-rails/rubocop-rspec.

## 0.7.6 and earlier

See git history - no changelog was kept before 1.0.0.
