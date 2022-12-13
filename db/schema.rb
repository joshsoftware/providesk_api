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

ActiveRecord::Schema.define(version: 2022_12_12_074312) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "activities", force: :cascade do |t|
    t.string "assigned_from", null: false
    t.string "assigned_to", null: false
    t.string "description"
    t.string "asset_url", default: [], array: true
    t.integer "current_ticket_status", default: 0
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "ticket_id"
    t.string "reason_for_update"
    t.integer "previous_ticket_status"
    t.index ["ticket_id"], name: "index_activities_on_ticket_id"
  end

  create_table "audits", force: :cascade do |t|
    t.integer "auditable_id"
    t.string "auditable_type"
    t.integer "associated_id"
    t.string "associated_type"
    t.integer "user_id"
    t.string "user_type"
    t.string "username"
    t.string "action"
    t.json "audited_changes"
    t.integer "version", default: 0
    t.string "comment"
    t.string "remote_address"
    t.string "request_uuid"
    t.datetime "created_at"
    t.index ["associated_type", "associated_id"], name: "associated_index"
    t.index ["auditable_type", "auditable_id", "version"], name: "auditable_index"
    t.index ["created_at"], name: "index_audits_on_created_at"
    t.index ["request_uuid"], name: "index_audits_on_request_uuid"
    t.index ["user_id", "user_type"], name: "user_index"
  end

  create_table "categories", force: :cascade do |t|
    t.string "name", null: false
    t.integer "priority", default: 0
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "department_id"
    t.index ["department_id"], name: "index_categories_on_department_id"
  end

  create_table "departments", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "organization_id"
    t.index ["organization_id"], name: "index_departments_on_organization_id"
  end

  create_table "organizations", force: :cascade do |t|
    t.string "name", null: false
    t.string "domain", default: [], array: true
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "roles", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "tickets", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.string "ticket_number"
    t.integer "status", default: 0
    t.integer "priority", default: 1
    t.integer "ticket_type"
    t.datetime "resolved_at"
    t.bigint "resolver_id"
    t.bigint "requester_id"
    t.bigint "department_id"
    t.bigint "category_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "organization_id"
    t.string "reason_for_update"
    t.string "asset_url", default: [], array: true
    t.date "eta"
    t.datetime "asked_for_update_at"
    t.index ["category_id"], name: "index_tickets_on_category_id"
    t.index ["department_id"], name: "index_tickets_on_department_id"
    t.index ["requester_id"], name: "index_tickets_on_requester_id"
    t.index ["resolver_id"], name: "index_tickets_on_resolver_id"
  end

  create_table "user_categories", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "category_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["category_id"], name: "index_user_categories_on_category_id"
    t.index ["user_id"], name: "index_user_categories_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "role_id"
    t.bigint "organization_id"
    t.bigint "department_id"
    t.index ["department_id"], name: "index_users_on_department_id"
    t.index ["organization_id"], name: "index_users_on_organization_id"
    t.index ["role_id"], name: "index_users_on_role_id"
  end

  add_foreign_key "categories", "departments"
  add_foreign_key "departments", "organizations"
  add_foreign_key "tickets", "categories"
  add_foreign_key "tickets", "departments"
  add_foreign_key "tickets", "users", column: "requester_id"
  add_foreign_key "tickets", "users", column: "resolver_id"
  add_foreign_key "user_categories", "categories"
  add_foreign_key "user_categories", "users"
  add_foreign_key "users", "departments"
  add_foreign_key "users", "organizations"
  add_foreign_key "users", "roles"
end
