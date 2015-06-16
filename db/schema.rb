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

ActiveRecord::Schema.define(version: 20150610133554) do

  create_table "keywords", primary_key: "ID", force: true do |t|
    t.string "word", limit: 30, null: false
  end

  create_table "messages", primary_key: "ID", force: true do |t|
    t.integer "userId",                  default: 0, null: false
    t.string  "phoneNum",    limit: 20
    t.integer "time",        limit: 8
    t.string  "content",     limit: 500
    t.integer "processCode"
    t.integer "_ID",                                 null: false
  end

  add_index "messages", ["userId"], name: "userID_idx", using: :btree

  create_table "patterns", primary_key: "ID", force: true do |t|
    t.string  "content",     limit: 300
    t.integer "patternType"
  end

  add_index "patterns", ["patternType"], name: "Pattern_TYPE_idx", using: :btree

  create_table "senders", primary_key: "ID", force: true do |t|
    t.string "phoneNum", limit: 20
  end

  create_table "spams", id: false, force: true do |t|
    t.integer "ID",                    null: false
    t.integer "patternID", default: 0
    t.integer "senderID",  default: 0
    t.integer "messageID", default: 0, null: false
  end

  add_index "spams", ["messageID"], name: "MESSAGE_ID_idx1", using: :btree
  add_index "spams", ["patternID"], name: "MESSAGE_ID_idx", using: :btree
  add_index "spams", ["senderID"], name: "SENDER_ID_idx", using: :btree

  create_table "typepatterns", primary_key: "ID", force: true do |t|
    t.string "Type", limit: 45
  end

  create_table "users", primary_key: "ID", force: true do |t|
    t.string  "phoneNum",       limit: 20
    t.string  "UDID",           limit: 20
    t.string  "regID",          limit: 200
    t.integer "lastReportTime", limit: 8
  end

end
