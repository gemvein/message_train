# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_08_27_171550) do
  create_table "action_text_rich_texts", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "groups", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.text "description"
    t.string "slug"
    t.string "title"
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "message_train_attachments", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.integer "message_train_message_id"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["message_train_message_id"], name: "index_message_train_attachments_on_message_train_message_id"
  end

  create_table "message_train_conversations", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.string "subject"
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "message_train_ignores", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.integer "message_train_conversation_id"
    t.integer "participant_id"
    t.string "participant_type"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["message_train_conversation_id"], name: "index_message_train_ignores_on_message_train_conversation_id"
    t.index ["participant_type", "participant_id"], name: "participant_index"
  end

  create_table "message_train_messages", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.boolean "draft", default: false
    t.integer "message_train_conversation_id"
    t.text "recipients_to_save"
    t.integer "sender_id"
    t.string "sender_type"
    t.string "subject"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["message_train_conversation_id"], name: "index_message_train_messages_on_message_train_conversation_id"
    t.index ["sender_type", "sender_id"], name: "index_message_train_messages_on_sender_type_and_sender_id"
  end

  create_table "message_train_receipts", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.boolean "marked_deleted", default: false
    t.boolean "marked_read", default: false
    t.boolean "marked_trash", default: false
    t.integer "message_train_message_id"
    t.integer "received_through_id"
    t.string "received_through_type"
    t.integer "recipient_id"
    t.string "recipient_type"
    t.boolean "sender", default: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["message_train_message_id", "recipient_type", "recipient_id"], name: "message_recipient", unique: true
    t.index ["message_train_message_id"], name: "index_message_train_receipts_on_message_train_message_id"
    t.index ["received_through_type", "received_through_id"], name: "index_message_train_receipts_on_received_through"
    t.index ["recipient_type", "recipient_id"], name: "index_message_train_receipts_on_recipient"
  end

  create_table "message_train_unsubscribes", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.integer "from_id"
    t.string "from_type"
    t.integer "recipient_id"
    t.string "recipient_type"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["from_type", "from_id"], name: "unsubscribe_from"
    t.index ["recipient_type", "recipient_id", "from_type", "from_id"], name: "unsubscribe", unique: true
    t.index ["recipient_type", "recipient_id"], name: "unsubscribe_recipient"
  end

  create_table "roles", force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.string "name"
    t.integer "resource_id"
    t.string "resource_type"
    t.datetime "updated_at", precision: nil
    t.index ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id"
    t.index ["name"], name: "index_roles_on_name"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.datetime "current_sign_in_at", precision: nil
    t.string "current_sign_in_ip"
    t.string "display_name"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "last_sign_in_at", precision: nil
    t.string "last_sign_in_ip"
    t.datetime "remember_created_at", precision: nil
    t.datetime "reset_password_sent_at", precision: nil
    t.string "reset_password_token"
    t.integer "sign_in_count", default: 0, null: false
    t.string "slug"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "users_roles", id: false, force: :cascade do |t|
    t.integer "role_id"
    t.integer "user_id"
    t.index ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "message_train_attachments", "message_train_messages"
  add_foreign_key "message_train_ignores", "message_train_conversations"
  add_foreign_key "message_train_messages", "message_train_conversations"
  add_foreign_key "message_train_receipts", "message_train_messages"
end
