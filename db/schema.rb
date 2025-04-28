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

ActiveRecord::Schema[8.0].define(version: 2025_04_28_185841) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "announcements", force: :cascade do |t|
    t.string "public_uid"
    t.bigint "barangay_id", null: false
    t.bigint "posted_by_id", null: false
    t.string "name"
    t.datetime "start_date"
    t.datetime "end_date"
    t.time "open_time"
    t.time "close_time"
    t.string "location"
    t.integer "max_patients", default: 1
    t.string "audience"
    t.integer "status", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["barangay_id"], name: "index_announcements_on_barangay_id"
    t.index ["posted_by_id"], name: "index_announcements_on_posted_by_id"
    t.index ["public_uid"], name: "index_announcements_on_public_uid", unique: true
  end

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

  create_table "data_migrations", primary_key: "version", id: :string, force: :cascade do |t|
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

  create_table "taggings", force: :cascade do |t|
    t.bigint "tag_id"
    t.string "taggable_type"
    t.bigint "taggable_id"
    t.string "tagger_type"
    t.bigint "tagger_id"
    t.string "context", limit: 128
    t.datetime "created_at", precision: nil
    t.string "tenant", limit: 128
    t.index ["context"], name: "index_taggings_on_context"
    t.index ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true
    t.index ["tag_id"], name: "index_taggings_on_tag_id"
    t.index ["taggable_id", "taggable_type", "context"], name: "taggings_taggable_context_idx"
    t.index ["taggable_id", "taggable_type", "tagger_id", "context"], name: "taggings_idy"
    t.index ["taggable_id"], name: "index_taggings_on_taggable_id"
    t.index ["taggable_type", "taggable_id"], name: "index_taggings_on_taggable_type_and_taggable_id"
    t.index ["taggable_type"], name: "index_taggings_on_taggable_type"
    t.index ["tagger_id", "tagger_type"], name: "index_taggings_on_tagger_id_and_tagger_type"
    t.index ["tagger_id"], name: "index_taggings_on_tagger_id"
    t.index ["tagger_type", "tagger_id"], name: "index_taggings_on_tagger_type_and_tagger_id"
    t.index ["tenant"], name: "index_taggings_on_tenant"
  end

  create_table "tags", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "taggings_count", default: 0
    t.index ["name"], name: "index_tags_on_name", unique: true
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

  add_foreign_key "announcements", "barangays"
  add_foreign_key "announcements", "users", column: "posted_by_id"
  add_foreign_key "subdivisions", "barangays"
  add_foreign_key "taggings", "tags"
  add_foreign_key "users", "barangays"
  add_foreign_key "users", "subdivisions"
end
