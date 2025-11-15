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

ActiveRecord::Schema[8.1].define(version: 2025_11_15_211554) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "beta_requests", force: :cascade do |t|
    t.string "company"
    t.datetime "created_at", null: false
    t.string "email"
    t.inet "ip"
    t.text "message"
    t.string "name"
    t.string "phone"
    t.datetime "updated_at", null: false
    t.text "user_agent"
  end

  create_table "companies", force: :cascade do |t|
    t.string "address"
    t.datetime "created_at", null: false
    t.string "logo"
    t.string "name"
    t.string "slug", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_companies_on_slug", unique: true
  end

  create_table "customers", force: :cascade do |t|
    t.string "address"
    t.bigint "company_id", null: false
    t.datetime "created_at", null: false
    t.string "email"
    t.string "name"
    t.text "notes"
    t.string "phone"
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_customers_on_company_id"
  end

  create_table "invoices", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.datetime "created_at", null: false
    t.bigint "job_id", null: false
    t.string "status"
    t.decimal "subtotal", precision: 10, scale: 2
    t.decimal "tax", precision: 10, scale: 2
    t.decimal "total", precision: 10, scale: 2
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_invoices_on_company_id"
    t.index ["job_id"], name: "index_invoices_on_job_id"
  end

  create_table "jobs", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.text "complaint"
    t.datetime "created_at", null: false
    t.bigint "customer_id", null: false
    t.text "diagnosis"
    t.string "model_number"
    t.text "notes"
    t.string "serial_number"
    t.datetime "starts_at"
    t.string "status"
    t.integer "technician_id"
    t.datetime "updated_at", null: false
    t.text "work_performed"
    t.index ["company_id"], name: "index_jobs_on_company_id"
    t.index ["customer_id"], name: "index_jobs_on_customer_id"
  end

  create_table "line_items", force: :cascade do |t|
    t.decimal "amount", precision: 10, scale: 2
    t.datetime "created_at", null: false
    t.string "description"
    t.bigint "invoice_id", null: false
    t.string "item_type"
    t.datetime "updated_at", null: false
    t.index ["invoice_id"], name: "index_line_items_on_invoice_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "company_id"
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "name"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.string "role"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "customers", "companies"
  add_foreign_key "invoices", "companies"
  add_foreign_key "invoices", "jobs"
  add_foreign_key "jobs", "companies"
  add_foreign_key "jobs", "customers"
  add_foreign_key "line_items", "invoices"
end
