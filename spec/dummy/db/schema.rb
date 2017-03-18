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

ActiveRecord::Schema.define(version: 20160207190409) do

  create_table "groups", force: :cascade do |t|
    t.string   "title"
    t.string   "slug"
    t.text     "description"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "message_train_attachments", force: :cascade do |t|
    t.integer  "message_train_message_id"
    t.string   "attachment_file_name"
    t.string   "attachment_content_type"
    t.integer  "attachment_file_size"
    t.datetime "attachment_updated_at"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.index ["message_train_message_id"], name: "index_message_train_attachments_on_message_train_message_id"
  end

  create_table "message_train_conversations", force: :cascade do |t|
    t.string   "subject"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "message_train_ignores", force: :cascade do |t|
    t.string   "participant_type"
    t.integer  "participant_id"
    t.integer  "message_train_conversation_id"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.index ["message_train_conversation_id"], name: "index_message_train_ignores_on_message_train_conversation_id"
    t.index ["participant_type", "participant_id"], name: "participant_index"
  end

  create_table "message_train_messages", force: :cascade do |t|
    t.integer  "message_train_conversation_id"
    t.string   "sender_type"
    t.integer  "sender_id"
    t.text     "recipients_to_save"
    t.string   "subject"
    t.text     "body"
    t.boolean  "draft",                         default: false
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
    t.index ["message_train_conversation_id"], name: "index_message_train_messages_on_message_train_conversation_id"
    t.index ["sender_type", "sender_id"], name: "index_message_train_messages_on_sender_type_and_sender_id"
  end

  create_table "message_train_receipts", force: :cascade do |t|
    t.string   "recipient_type"
    t.integer  "recipient_id"
    t.integer  "message_train_message_id"
    t.boolean  "marked_read",              default: false
    t.boolean  "marked_trash",             default: false
    t.boolean  "marked_deleted",           default: false
    t.boolean  "sender",                   default: false
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.string   "received_through_type"
    t.integer  "received_through_id"
    t.index ["message_train_message_id", "recipient_type", "recipient_id"], name: "message_recipient", unique: true
    t.index ["message_train_message_id"], name: "index_message_train_receipts_on_message_train_message_id"
    t.index ["received_through_type", "received_through_id"], name: "index_message_train_receipts_on_received_through"
    t.index ["recipient_type", "recipient_id"], name: "index_message_train_receipts_on_recipient"
  end

  create_table "message_train_unsubscribes", force: :cascade do |t|
    t.string   "recipient_type"
    t.integer  "recipient_id"
    t.string   "from_type"
    t.integer  "from_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.index ["from_type", "from_id"], name: "unsubscribe_from"
    t.index ["recipient_type", "recipient_id", "from_type", "from_id"], name: "unsubscribe", unique: true
    t.index ["recipient_type", "recipient_id"], name: "unsubscribe_recipient"
  end

  create_table "roles", force: :cascade do |t|
    t.string   "name"
    t.string   "resource_type"
    t.integer  "resource_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id"
    t.index ["name"], name: "index_roles_on_name"
  end

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
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "users_roles", id: false, force: :cascade do |t|
    t.integer "user_id"
    t.integer "role_id"
    t.index ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id"
  end

end
