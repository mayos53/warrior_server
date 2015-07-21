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

ActiveRecord::Schema.define(version: 20150720144027) do

  create_table "admins", force: true do |t|
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
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "admins", ["email"], name: "index_admins_on_email", unique: true, using: :btree
  add_index "admins", ["reset_password_token"], name: "index_admins_on_reset_password_token", unique: true, using: :btree

  create_table "companies", force: true do |t|
    t.string "company_name",     limit: 70
    t.string "company_phonenum", limit: 45
    t.string "company_faxnum",   limit: 45
    t.string "company_hj_url",   limit: 70
    t.string "company_id",       limit: 9,  null: false
  end

  add_index "companies", ["company_id"], name: "company_id_UNIQUE", unique: true, using: :btree
  add_index "companies", ["id"], name: "id_UNIQUE", unique: true, using: :btree

  create_table "company_for_senders", force: true do |t|
    t.integer "company_id", limit: 8
    t.integer "sender_id",  limit: 8
  end

  add_index "company_for_senders", ["id"], name: "id_UNIQUE", unique: true, using: :btree

  create_table "message_patterns", force: true do |t|
    t.integer "pattern_type_id"
    t.text    "pattern_text"
    t.integer "sender_id"
  end

  add_index "message_patterns", ["id"], name: "id_UNIQUE", unique: true, using: :btree

  create_table "message_statuses", force: true do |t|
    t.string "internal_name", limit: 50, null: false
    t.string "display_text",  limit: 50, null: false
  end

  create_table "pattern_types", force: true do |t|
    t.string "internal_name", limit: 50, null: false
    t.string "display_text",  limit: 50, null: false
  end

  add_index "pattern_types", ["id"], name: "id_UNIQUE", unique: true, using: :btree

  create_table "sender_types", force: true do |t|
    t.string "internal_name", limit: 50, null: false
    t.string "display_text",  limit: 50, null: false
  end

  add_index "sender_types", ["id"], name: "id_UNIQUE", unique: true, using: :btree

  create_table "senders", force: true do |t|
    t.string  "sender_from",          limit: 50
    t.binary  "is_sender_black_list", limit: 1,  default: "1", null: false
    t.integer "sender_type_id",       limit: 8,                null: false
  end

  add_index "senders", ["id"], name: "id_UNIQUE", unique: true, using: :btree

  create_table "sms_messages", force: true do |t|
    t.integer "user_id",           limit: 8, null: false
    t.integer "sender_id",                   null: false
    t.integer "message_status_id",           null: false
    t.text    "body_text",                   null: false
    t.integer "received_time",     limit: 8, null: false
  end

  add_index "sms_messages", ["id"], name: "id_UNIQUE", unique: true, using: :btree

  create_table "suspicious_keywords", force: true do |t|
    t.string "keyword", limit: 60, null: false
  end

  create_table "user_patterns", force: true do |t|
    t.integer "user_id",            limit: 8, null: false
    t.integer "message_pattern_id",           null: false
    t.binary  "is_spam",            limit: 1, null: false
  end

  create_table "users", force: true do |t|
    t.string  "udid",              limit: 36
    t.string  "reg_id"
    t.string  "phone_num",         limit: 12
    t.integer "confirmation_code", limit: 2
    t.integer "last_report_time",  limit: 8
    t.integer "agreement_time",    limit: 8
    t.integer "confirmation_time", limit: 8
  end

  add_index "users", ["id"], name: "id_UNIQUE", unique: true, using: :btree

end
