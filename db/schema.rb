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

ActiveRecord::Schema[8.1].define(version: 2026_10_28_000100) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "account_season_passes", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.bigint "season_pass_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "season_pass_id"], name: "unique_account_season_passes_identity", unique: true
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
    t.index ["account_id", "resort_id", "start_date"], name: "unique_account_ski_days_identity", unique: true
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
    t.index ["provider", "uid"], name: "unique_accounts_identity", unique: true
    t.index ["reset_password_token"], name: "index_accounts_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_accounts_on_unlock_token", unique: true
  end

  create_table "beds", force: :cascade do |t|
    t.bigint "room_id", null: false
    t.string "style"
    t.string "size"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "capacity"
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
    t.integer "guest_count", default: 0, null: false
    t.integer "cars", default: 0, null: false
    t.index ["lodging_id", "user_id", "date"], name: "unique_calendars_identity", unique: true
    t.index ["lodging_id"], name: "index_calendars_on_lodging_id"
    t.index ["user_id"], name: "index_calendars_on_user_id"
  end

  create_table "house_ledger_entries", force: :cascade do |t|
    t.bigint "house_season_id", null: false
    t.bigint "recorded_by_id"
    t.string "kind", null: false
    t.string "description", null: false
    t.date "month_on", null: false
    t.bigint "amount_cents", null: false
    t.string "source_key"
    t.jsonb "source_data", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["house_season_id", "source_key"], name: "index_house_ledger_entries_on_house_season_id_and_source_key", unique: true
    t.index ["house_season_id"], name: "index_house_ledger_entries_on_house_season_id"
    t.index ["recorded_by_id"], name: "index_house_ledger_entries_on_recorded_by_id"
    t.check_constraint "amount_cents > 0", name: "house_ledger_positive_amount"
  end

  create_table "house_payments", force: :cascade do |t|
    t.bigint "house_ledger_entry_id", null: false
    t.bigint "recorded_by_id"
    t.bigint "amount_cents", null: false
    t.date "paid_on"
    t.boolean "source_reported", default: false, null: false
    t.string "reference"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["house_ledger_entry_id"], name: "index_house_payments_on_house_ledger_entry_id"
    t.index ["recorded_by_id"], name: "index_house_payments_on_recorded_by_id"
    t.check_constraint "amount_cents > 0", name: "house_payment_positive_amount"
  end

  create_table "house_seasons", force: :cascade do |t|
    t.bigint "lodging_id", null: false
    t.string "name", null: false
    t.date "starts_on", null: false
    t.date "ends_on", null: false
    t.string "policy_status", default: "draft", null: false
    t.bigint "monthly_rent_cents"
    t.integer "participant_count"
    t.jsonb "guest_rates", default: {}, null: false
    t.bigint "dog_fee_cents"
    t.string "dog_fee_basis", default: "unconfirmed", null: false
    t.integer "free_nights", default: 0, null: false
    t.text "rules"
    t.text "source_notes"
    t.jsonb "source_summary", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["lodging_id", "starts_on", "ends_on"], name: "unique_house_season_dates", unique: true
    t.index ["lodging_id"], name: "index_house_seasons_on_lodging_id"
    t.check_constraint "ends_on >= starts_on", name: "house_season_date_order"
  end

  create_table "house_sheet_cells", force: :cascade do |t|
    t.bigint "house_season_id", null: false
    t.string "kind", null: false
    t.date "observed_on", null: false
    t.string "person_label"
    t.string "room_label"
    t.string "bed_label"
    t.string "value", null: false
    t.string "source_key", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["house_season_id", "source_key"], name: "index_house_sheet_cells_on_house_season_id_and_source_key", unique: true
    t.index ["house_season_id"], name: "index_house_sheet_cells_on_house_season_id"
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
    t.date "season_start"
    t.date "season_end"
    t.integer "max_cars"
  end

  create_table "resorts", force: :cascade do |t|
    t.string "name"
    t.string "city"
    t.string "state"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "lat", precision: 10, scale: 6
    t.decimal "long", precision: 10, scale: 6
    t.index "lower((name)::text)", name: "unique_resorts_name", unique: true
  end

  create_table "roommates", force: :cascade do |t|
    t.string "role"
    t.bigint "user_id", null: false
    t.bigint "lodging_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["lodging_id", "user_id"], name: "unique_roommates_identity", unique: true
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
    t.index ["season_pass_id", "resort_id"], name: "unique_season_pass_resorts_identity", unique: true
    t.index ["season_pass_id"], name: "index_season_pass_resorts_on_season_pass_id"
  end

  create_table "season_passes", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index "lower((name)::text)", name: "unique_season_passes_name", unique: true
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
    t.index ["account_id"], name: "unique_users_identity", unique: true
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
  add_foreign_key "house_ledger_entries", "accounts", column: "recorded_by_id"
  add_foreign_key "house_ledger_entries", "house_seasons"
  add_foreign_key "house_payments", "accounts", column: "recorded_by_id"
  add_foreign_key "house_payments", "house_ledger_entries"
  add_foreign_key "house_seasons", "lodgings"
  add_foreign_key "house_sheet_cells", "house_seasons"
  add_foreign_key "roommates", "lodgings"
  add_foreign_key "roommates", "users"
  add_foreign_key "rooms", "lodgings"
  add_foreign_key "season_pass_resorts", "resorts"
  add_foreign_key "season_pass_resorts", "season_passes"
  add_foreign_key "users", "accounts"
end
