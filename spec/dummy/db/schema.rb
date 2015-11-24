# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20151124001417) do

  create_table "groups", force: :cascade do |t|
    t.string   "title"
    t.string   "slug"
    t.text     "description"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "message_train_attachments", force: :cascade do |t|
    t.integer  "message_id"
    t.string   "attachment_file_name"
    t.string   "attachment_content_type"
    t.integer  "attachment_file_size"
    t.datetime "attachment_updated_at"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "message_train_attachments", ["message_id"], name: "index_message_train_attachments_on_message_id"

  create_table "message_train_conversations", force: :cascade do |t|
    t.string   "subject"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "message_train_ignores", force: :cascade do |t|
    t.integer  "participant_id"
    t.string   "participant_type"
    t.integer  "conversation_id"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  add_index "message_train_ignores", ["conversation_id"], name: "index_message_train_ignores_on_conversation_id"
  add_index "message_train_ignores", ["participant_type", "participant_id"], name: "participant_index"

  create_table "message_train_messages", force: :cascade do |t|
    t.integer  "conversation_id"
    t.integer  "sender_id"
    t.string   "sender_type"
    t.text     "recipients_to_save"
    t.string   "subject"
    t.text     "body"
    t.boolean  "draft",              default: false
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
  end

  add_index "message_train_messages", ["conversation_id"], name: "index_message_train_messages_on_conversation_id"
  add_index "message_train_messages", ["sender_type", "sender_id"], name: "index_message_train_messages_on_sender_type_and_sender_id"

  create_table "message_train_receipts", force: :cascade do |t|
    t.integer  "recipient_id"
    t.string   "recipient_type"
    t.integer  "message_id"
    t.boolean  "marked_read",           default: false
    t.boolean  "marked_trash",          default: false
    t.boolean  "marked_deleted",        default: false
    t.boolean  "sender",                default: false
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.integer  "received_through_id"
    t.string   "received_through_type"
  end

  add_index "message_train_receipts", ["message_id", "recipient_type", "recipient_id"], name: "message_recipient", unique: true
  add_index "message_train_receipts", ["message_id"], name: "index_message_train_receipts_on_message_id"
  add_index "message_train_receipts", ["received_through_type", "received_through_id"], name: "index_message_train_receipts_on_received_through"
  add_index "message_train_receipts", ["recipient_type", "recipient_id"], name: "index_message_train_receipts_on_recipient"

  create_table "message_train_unsubscribes", force: :cascade do |t|
    t.integer  "recipient_id"
    t.string   "recipient_type"
    t.integer  "from_id"
    t.string   "from_type"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "message_train_unsubscribes", ["from_type", "from_id"], name: "unsubscribe_from"
  add_index "message_train_unsubscribes", ["recipient_type", "recipient_id", "from_type", "from_id"], name: "unsubscribes", unique: true
  add_index "message_train_unsubscribes", ["recipient_type", "recipient_id"], name: "unsubscribe_recipient"

  create_table "roles", force: :cascade do |t|
    t.string   "name"
    t.integer  "resource_id"
    t.string   "resource_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "roles", ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id"
  add_index "roles", ["name"], name: "index_roles_on_name"

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "display_name"
    t.string   "slug"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true

  create_table "users_roles", id: false, force: :cascade do |t|
    t.integer "user_id"
    t.integer "role_id"
  end

  add_index "users_roles", ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id"

end
