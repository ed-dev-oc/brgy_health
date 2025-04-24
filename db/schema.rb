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

ActiveRecord::Schema[8.0].define(version: 2025_04_27_091339) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "barangays", force: :cascade do |t|
    t.string "name"
    t.string "slug"
    t.integer "subdivision_type", default: 0
    t.string "region"
    t.string "province"
    t.string "city"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "subdomain"
    t.index ["region", "province", "city", "name"], name: "index_barangays_on_region_and_province_and_city_and_name", unique: true
    t.index ["region", "province", "city", "slug"], name: "index_barangays_on_region_and_province_and_city_and_slug", unique: true
  end

  create_table "health_programs", force: :cascade do |t|
    t.bigint "barangay_id", null: false
    t.string "name"
    t.text "description"
    t.integer "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["barangay_id"], name: "index_health_programs_on_barangay_id"
  end

  create_table "subdivisions", force: :cascade do |t|
    t.bigint "barangay_id", null: false
    t.string "name"
    t.string "slug"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["barangay_id"], name: "index_subdivisions_on_barangay_id"
    t.index ["name", "barangay_id"], name: "index_subdivisions_on_name_and_barangay_id", unique: true
    t.index ["slug", "barangay_id"], name: "index_subdivisions_on_slug_and_barangay_id", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "public_uid"
    t.string "first_name"
    t.string "middle_name"
    t.string "last_name"
    t.string "suffix"
    t.string "phone_number"
    t.integer "role"
    t.bigint "barangay_id"
    t.bigint "subdivision_id"
    t.index ["barangay_id"], name: "index_users_on_barangay_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["first_name", "middle_name", "last_name", "suffix"], name: "index_users_on_full_name", unique: true
    t.index ["phone_number"], name: "index_users_on_phone_number", unique: true
    t.index ["public_uid"], name: "index_users_on_public_uid", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["role"], name: "index_users_on_role"
    t.index ["subdivision_id"], name: "index_users_on_subdivision_id"
  end

  add_foreign_key "health_programs", "barangays"
  add_foreign_key "subdivisions", "barangays"
  add_foreign_key "users", "barangays"
  add_foreign_key "users", "subdivisions"
end
