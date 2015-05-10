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

  create_table "Keywords", primary_key: "ID", force: true do |t|
    t.string "word", limit: 30, null: false
  end

  create_table "Messages", primary_key: "ID", force: true do |t|
    t.integer "userId"
    t.string  "phoneNum",    limit: 20
    t.integer "time",        limit: 8
    t.string  "content",     limit: 300
    t.integer "processCode"
  end

  add_index "messages", ["userId"], name: "userID_idx", using: :btree

  create_table "Patterns", primary_key: "ID", force: true do |t|
    t.string "content", limit: 300
  end

  create_table "Senders", primary_key: "ID", force: true do |t|
    t.string "PhoneNum", limit: 20
  end

  create_table "Spams", primary_key: "ID", force: true do |t|
    t.integer "patternID"
    t.integer "senderID"
    t.integer "messageID"
  end

  add_index "spams", ["messageID"], name: "MESSAGE_ID_idx1", using: :btree
  add_index "spams", ["patternID"], name: "MESSAGE_ID_idx", using: :btree
  add_index "spams", ["senderID"], name: "SENDER_ID_idx", using: :btree

  create_table "Users", primary_key: "ID", force: true do |t|
    t.string "phoneNum", limit: 20
    t.string "UDID",     limit: 20
    t.string "regID",    limit: 20
  end

end