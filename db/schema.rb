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

ActiveRecord::Schema.define(version: 0) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "message_patterns", force: true do |t|
    t.integer "sender_id",       null: false
    t.integer "pattern_type_id", null: false
    t.text    "pattern_text",    null: false
  end

  add_index "message_patterns", ["id"], name: "MessagePattern_MessagePatternID_idx", using: :btree
  add_index "message_patterns", ["id"], name: "MessagePattern_MessagePatternID_key", unique: true, using: :btree

  create_table "message_statuses", id: false, force: true do |t|
    t.integer "id",                       null: false
    t.string  "internal_name", limit: 50, null: false
    t.string  "display_text",  limit: 50, null: false
  end

  add_index "message_statuses", ["id"], name: "MessageStatus_MessageStatusID_key", unique: true, using: :btree
  add_index "message_statuses", ["id"], name: "MessageStatus_MessageStatus_ID_idx", using: :btree

  create_table "pattern_types", force: true do |t|
    t.string "internal_name", limit: 50, null: false
    t.string "display_text",  limit: 50, null: false
  end

  add_index "pattern_types", ["id"], name: "PatternType_PatternTypeID_idx", using: :btree
  add_index "pattern_types", ["id"], name: "PatternType_PatternTypeID_key", unique: true, using: :btree

  create_table "sender_types", force: true do |t|
    t.string "internal_name", limit: 50, null: false
    t.string "display_text",  limit: 50, null: false
  end

  add_index "sender_types", ["id"], name: "SenderType_SenderTypeID_idx", using: :btree
  add_index "sender_types", ["id"], name: "SenderType_SenderTypeID_key", unique: true, using: :btree

  create_table "senders", force: true do |t|
    t.string  "sender_from",          limit: 50
    t.integer "sender_type",                                     null: false
    t.boolean "is_sender_black_list",            default: false, null: false
  end

  add_index "senders", ["id"], name: "Sender_SenderID_idx", using: :btree
  add_index "senders", ["id"], name: "Sender_SenderID_key", unique: true, using: :btree

  create_table "sms_messages", id: false, force: true do |t|
    t.integer "id",                limit: 8, null: false
    t.integer "user_id",           limit: 8, null: false
    t.integer "sender_id",                   null: false
    t.integer "message_status_id",           null: false
    t.text    "body_text",                   null: false
    t.integer "received_time",     limit: 8, null: false
  end

  add_index "sms_messages", ["id"], name: "SMSMessages_SMSMessagesID_idx", using: :btree
  add_index "sms_messages", ["id"], name: "SMSMessages_SMSMessagesID_key", unique: true, using: :btree
  add_index "sms_messages", ["message_status_id"], name: "fki_MessageStatus", using: :btree
  add_index "sms_messages", ["sender_id"], name: "fki_SenderID", using: :btree
  add_index "sms_messages", ["user_id"], name: "fki_UserID (FK)", using: :btree

  create_table "suspicious_keywords", force: true do |t|
    t.string "keyword", limit: 60, null: false
  end

  add_index "suspicious_keywords", ["id"], name: "SuspiciousKeyWords_SuspiciousKeyWordsID_idx", using: :btree
  add_index "suspicious_keywords", ["id"], name: "SuspiciousKeyWords_SuspiciousKeyWordsID_key", unique: true, using: :btree

  create_table "user_patterns", force: true do |t|
    t.integer "user_id",            limit: 8,                 null: false
    t.integer "message_pattern_id",                           null: false
    t.boolean "is_spam",                      default: false, null: false
  end

  add_index "user_patterns", ["message_pattern_id"], name: "fki_MessagePatternID", using: :btree
  add_index "user_patterns", ["user_id"], name: "fki_UserID", using: :btree

  create_table "users", force: true do |t|
    t.string  "udid",              limit: 36
    t.string  "reg_id",            limit: 40
    t.string  "phone_num",         limit: 12
    t.integer "confirmation_code", limit: 2
    t.integer "last_report_time",  limit: 8
    t.integer "agreement_time",    limit: 8
    t.integer "confirmation_time", limit: 8
  end

  add_index "users", ["id"], name: "Users_UserID_idx", using: :btree
  add_index "users", ["id"], name: "Users_UserID_key", unique: true, using: :btree

end
