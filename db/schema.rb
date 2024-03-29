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

ActiveRecord::Schema[7.0].define(version: 2024_03_02_001415) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "account_season_passes", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.bigint "season_pass_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_account_season_passes_on_account_id"
    t.index ["season_pass_id"], name: "index_account_season_passes_on_season_pass_id"
  end

  create_table "account_ski_days", force: :cascade do |t|
    t.string "status"
    t.date "start_date"
    t.bigint "account_id", null: false
    t.bigint "resort_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_account_ski_days_on_account_id"
    t.index ["resort_id"], name: "index_account_ski_days_on_resort_id"
  end

  create_table "accounts", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "provider"
    t.string "uid"
    t.index ["confirmation_token"], name: "index_accounts_on_confirmation_token", unique: true
    t.index ["email"], name: "index_accounts_on_email", unique: true
    t.index ["reset_password_token"], name: "index_accounts_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_accounts_on_unlock_token", unique: true
  end

  create_table "beds", force: :cascade do |t|
    t.bigint "room_id", null: false
    t.string "style"
    t.string "size"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["room_id"], name: "index_beds_on_room_id"
  end

  create_table "blackout_days", force: :cascade do |t|
    t.date "start_date"
    t.date "end_date"
    t.bigint "season_pass_id", null: false
    t.bigint "resort_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["resort_id"], name: "index_blackout_days_on_resort_id"
    t.index ["season_pass_id"], name: "index_blackout_days_on_season_pass_id"
  end

  create_table "calendars", force: :cascade do |t|
    t.string "status"
    t.date "date"
    t.bigint "user_id", null: false
    t.bigint "lodging_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["lodging_id"], name: "index_calendars_on_lodging_id"
    t.index ["user_id"], name: "index_calendars_on_user_id"
  end

  create_table "lodgings", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.integer "max_guests"
    t.string "street"
    t.string "city"
    t.string "state"
    t.string "zip_code"
    t.string "country"
    t.decimal "lat", precision: 10, scale: 6
    t.decimal "lon", precision: 10, scale: 6
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "address2"
  end

  create_table "resorts", force: :cascade do |t|
    t.string "name"
    t.string "city"
    t.string "state"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "lat", precision: 10, scale: 6
    t.decimal "long", precision: 10, scale: 6
  end

  create_table "roommates", force: :cascade do |t|
    t.string "role"
    t.bigint "user_id", null: false
    t.bigint "lodging_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["lodging_id"], name: "index_roommates_on_lodging_id"
    t.index ["user_id"], name: "index_roommates_on_user_id"
  end

  create_table "rooms", force: :cascade do |t|
    t.bigint "lodging_id", null: false
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "room_type"
    t.index ["lodging_id"], name: "index_rooms_on_lodging_id"
  end

  create_table "season_pass_resorts", force: :cascade do |t|
    t.bigint "season_pass_id", null: false
    t.bigint "resort_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["resort_id"], name: "index_season_pass_resorts_on_resort_id"
    t.index ["season_pass_id"], name: "index_season_pass_resorts_on_season_pass_id"
  end

  create_table "season_passes", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "full_name"
    t.string "avatar_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "first_name"
    t.string "last_name"
    t.bigint "account_id", null: false
    t.string "preferred_name"
    t.string "about"
    t.string "ride_type"
    t.string "level"
    t.string "phone_number"
    t.string "address1"
    t.string "address2"
    t.string "country"
    t.string "city"
    t.string "state"
    t.string "zip_code"
    t.string "birthday"
    t.text "allergies"
    t.string "venmo_url"
    t.string "instagram_url"
    t.string "facebook_url"
    t.index ["account_id"], name: "index_users_on_account_id"
  end

  add_foreign_key "account_season_passes", "accounts"
  add_foreign_key "account_season_passes", "season_passes"
  add_foreign_key "account_ski_days", "accounts"
  add_foreign_key "account_ski_days", "resorts"
  add_foreign_key "beds", "rooms"
  add_foreign_key "blackout_days", "resorts"
  add_foreign_key "blackout_days", "season_passes"
  add_foreign_key "calendars", "lodgings"
  add_foreign_key "calendars", "users"
  add_foreign_key "roommates", "lodgings"
  add_foreign_key "roommates", "users"
  add_foreign_key "rooms", "lodgings"
  add_foreign_key "season_pass_resorts", "resorts"
  add_foreign_key "season_pass_resorts", "season_passes"
  add_foreign_key "users", "accounts"
end
