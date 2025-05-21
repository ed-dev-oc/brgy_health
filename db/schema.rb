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

ActiveRecord::Schema[8.0].define(version: 2025_05_19_142442) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "action_text_rich_texts", force: :cascade do |t|
    t.string "name", null: false
    t.text "body"
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

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
    t.bigint "health_program_id"
    t.index ["barangay_id"], name: "index_announcements_on_barangay_id"
    t.index ["health_program_id"], name: "index_announcements_on_health_program_id"
    t.index ["posted_by_id"], name: "index_announcements_on_posted_by_id"
    t.index ["public_uid"], name: "index_announcements_on_public_uid", unique: true
  end

  create_table "appointments", force: :cascade do |t|
    t.string "public_uid"
    t.bigint "barangay_id", null: false
    t.bigint "announcement_id", null: false
    t.bigint "health_worker_id"
    t.bigint "patient_id", null: false
    t.datetime "scheduled_at"
    t.text "reason"
    t.text "notes"
    t.bigint "follow_up_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "status", default: 0
    t.index ["announcement_id"], name: "index_appointments_on_announcement_id"
    t.index ["barangay_id"], name: "index_appointments_on_barangay_id"
    t.index ["follow_up_id"], name: "index_appointments_on_follow_up_id"
    t.index ["health_worker_id"], name: "index_appointments_on_health_worker_id"
    t.index ["patient_id"], name: "index_appointments_on_patient_id"
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

  create_table "health_programs", force: :cascade do |t|
    t.bigint "barangay_id", null: false
    t.string "name"
    t.text "description"
    t.integer "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["barangay_id"], name: "index_health_programs_on_barangay_id"
  end

  create_table "noticed_events", force: :cascade do |t|
    t.string "type"
    t.string "record_type"
    t.bigint "record_id"
    t.jsonb "params"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "notifications_count"
    t.index ["record_type", "record_id"], name: "index_noticed_events_on_record"
  end

  create_table "noticed_notifications", force: :cascade do |t|
    t.string "type"
    t.bigint "event_id", null: false
    t.string "recipient_type", null: false
    t.bigint "recipient_id", null: false
    t.datetime "read_at", precision: nil
    t.datetime "seen_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_noticed_notifications_on_event_id"
    t.index ["recipient_type", "recipient_id"], name: "index_noticed_notifications_on_recipient"
  end

  create_table "pages", force: :cascade do |t|
    t.bigint "barangay_id"
    t.string "title"
    t.string "subheadline"
    t.integer "section"
    t.decimal "latitude"
    t.decimal "longitude"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["barangay_id"], name: "index_pages_on_barangay_id"
  end

  create_table "push_subscriptions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "endpoint"
    t.string "p256dh"
    t.string "auth"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_push_subscriptions_on_user_id"
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

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "announcements", "barangays"
  add_foreign_key "announcements", "health_programs"
  add_foreign_key "announcements", "users", column: "posted_by_id"
  add_foreign_key "appointments", "announcements"
  add_foreign_key "appointments", "appointments", column: "follow_up_id"
  add_foreign_key "appointments", "barangays"
  add_foreign_key "appointments", "users", column: "health_worker_id"
  add_foreign_key "appointments", "users", column: "patient_id"
  add_foreign_key "health_programs", "barangays"
  add_foreign_key "pages", "barangays"
  add_foreign_key "push_subscriptions", "users"
  add_foreign_key "subdivisions", "barangays"
  add_foreign_key "taggings", "tags"
  add_foreign_key "users", "barangays"
  add_foreign_key "users", "subdivisions"
end
