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

ActiveRecord::Schema.define(version: 2019_04_03_100839) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "bargains", force: :cascade do |t|
    t.string "now_winner"
    t.text "all_bid", default: [], array: true
    t.string "channel_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "now_win_bid"
  end

  create_table "bombs", force: :cascade do |t|
    t.integer "now_min", default: 0
    t.integer "now_max"
    t.integer "user_number", default: 0
    t.integer "code"
    t.string "channel_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "channels", force: :cascade do |t|
    t.string "channel_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "now_gaming", default: "no"
  end

  create_table "keyword_mappings", force: :cascade do |t|
    t.string "keyword"
    t.string "message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "channel_id"
  end

  create_table "killers", force: :cascade do |t|
    t.string "killer"
    t.text "players", default: [], array: true
    t.boolean "game_begin", default: false
    t.string "channel_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "round"
  end

  create_table "receiveds", force: :cascade do |t|
    t.string "channel_id"
    t.string "text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "replies", force: :cascade do |t|
    t.string "channel_id"
    t.string "text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "shoot_the_gates", force: :cascade do |t|
    t.string "card1"
    t.string "card2"
    t.integer "stakes", default: 0
    t.string "gambling", default: "No"
    t.string "channel_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "cards", default: [], array: true
    t.text "player_result", default: [["0", "0", "0"]], array: true
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

end
