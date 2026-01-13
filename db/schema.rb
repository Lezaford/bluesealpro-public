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

ActiveRecord::Schema[8.1].define(version: 2026_01_12_190000) do
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
    t.string "address_line1"
    t.string "address_line2"
    t.string "city"
    t.datetime "created_at", null: false
    t.string "ein"
    t.string "email"
    t.string "logo"
    t.string "name"
    t.string "phone"
    t.string "slug", null: false
    t.string "state"
    t.string "time_zone", default: "America/New_York"
    t.datetime "updated_at", null: false
    t.string "website_url"
    t.string "zip"
    t.index ["slug"], name: "index_companies_on_slug", unique: true
  end

  create_table "customers", force: :cascade do |t|
    t.string "accepts_bills_from"
    t.text "additional_emails"
    t.string "address"
    t.string "address1"
    t.string "address2"
    t.boolean "address_1_billing", default: true
    t.string "address_1_city"
    t.text "address_1_notes"
    t.string "address_1_postal_code"
    t.string "address_1_state"
    t.string "address_1_street_line_1"
    t.string "address_1_street_line_2"
    t.boolean "address_2_billing", default: false
    t.string "address_2_city"
    t.text "address_2_notes"
    t.string "address_2_postal_code"
    t.string "address_2_state"
    t.string "address_2_street_line_1"
    t.string "address_2_street_line_2"
    t.boolean "address_3_billing", default: false
    t.string "address_3_city"
    t.text "address_3_notes"
    t.string "address_3_postal_code"
    t.string "address_3_state"
    t.string "address_3_street_line_1"
    t.string "address_3_street_line_2"
    t.boolean "address_4_billing", default: false
    t.string "address_4_city"
    t.text "address_4_notes"
    t.string "address_4_postal_code"
    t.string "address_4_state"
    t.string "address_4_street_line_1"
    t.string "address_4_street_line_2"
    t.string "bills_to"
    t.string "city"
    t.bigint "company_id", null: false
    t.string "company_name"
    t.datetime "created_at", null: false
    t.datetime "customer_created_at"
    t.boolean "customer_is_contractor", default: false, null: false
    t.boolean "customer_notifications_enabled", default: true, null: false
    t.string "customer_type"
    t.string "display_name"
    t.string "email"
    t.string "external_id"
    t.string "first_name"
    t.string "home_number"
    t.string "last_name"
    t.date "last_service_date"
    t.string "lead_source"
    t.decimal "lifetime_value", precision: 12, scale: 2, default: "0.0"
    t.string "mobile_number"
    t.string "name"
    t.text "notes"
    t.string "phone"
    t.string "role"
    t.string "state"
    t.string "tags"
    t.datetime "updated_at", null: false
    t.string "work_number"
    t.string "zip"
    t.index ["company_id", "email"], name: "index_customers_on_company_id_and_email"
    t.index ["company_id", "first_name"], name: "index_customers_on_company_id_and_first_name"
    t.index ["company_id", "last_name"], name: "index_customers_on_company_id_and_last_name"
    t.index ["company_id"], name: "index_customers_on_company_id"
    t.index ["display_name"], name: "index_customers_on_display_name"
    t.index ["email"], name: "index_customers_on_email"
    t.index ["external_id"], name: "index_customers_on_external_id", unique: true
    t.index ["first_name"], name: "index_customers_on_first_name"
    t.index ["last_name"], name: "index_customers_on_last_name"
    t.index ["mobile_number"], name: "index_customers_on_mobile_number"
    t.index ["phone"], name: "index_customers_on_phone"
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
    t.string "appliance_type"
    t.string "brand"
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

  create_table "solid_queue_blocked_executions", force: :cascade do |t|
    t.string "concurrency_key", null: false
    t.datetime "created_at", null: false
    t.datetime "expires_at", null: false
    t.bigint "job_id", null: false
    t.integer "priority", default: 0, null: false
    t.string "queue_name", null: false
    t.index ["concurrency_key", "priority", "job_id"], name: "index_solid_queue_blocked_executions_for_release"
    t.index ["expires_at", "concurrency_key"], name: "index_solid_queue_blocked_executions_for_maintenance"
    t.index ["job_id"], name: "index_solid_queue_blocked_executions_on_job_id", unique: true
  end

  create_table "solid_queue_claimed_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "job_id", null: false
    t.bigint "process_id"
    t.index ["job_id"], name: "index_solid_queue_claimed_executions_on_job_id", unique: true
    t.index ["process_id", "job_id"], name: "index_solid_queue_claimed_executions_on_process_id_and_job_id"
  end

  create_table "solid_queue_failed_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "error"
    t.bigint "job_id", null: false
    t.index ["job_id"], name: "index_solid_queue_failed_executions_on_job_id", unique: true
  end

  create_table "solid_queue_jobs", force: :cascade do |t|
    t.string "active_job_id"
    t.text "arguments"
    t.string "class_name", null: false
    t.string "concurrency_key"
    t.datetime "created_at", null: false
    t.datetime "finished_at"
    t.integer "priority", default: 0, null: false
    t.string "queue_name", null: false
    t.datetime "scheduled_at"
    t.datetime "updated_at", null: false
    t.index ["active_job_id"], name: "index_solid_queue_jobs_on_active_job_id"
    t.index ["class_name"], name: "index_solid_queue_jobs_on_class_name"
    t.index ["finished_at"], name: "index_solid_queue_jobs_on_finished_at"
    t.index ["queue_name", "finished_at"], name: "index_solid_queue_jobs_for_filtering"
    t.index ["scheduled_at", "finished_at"], name: "index_solid_queue_jobs_for_alerting"
  end

  create_table "solid_queue_pauses", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "queue_name", null: false
    t.index ["queue_name"], name: "index_solid_queue_pauses_on_queue_name", unique: true
  end

  create_table "solid_queue_processes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "hostname", null: false
    t.string "kind", null: false
    t.string "name", null: false
    t.integer "pid", null: false
    t.index ["hostname", "pid"], name: "index_solid_queue_processes_on_hostname_and_pid", unique: true
  end

  create_table "solid_queue_ready_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "job_id", null: false
    t.integer "priority", default: 0, null: false
    t.string "queue_name", null: false
    t.index ["job_id"], name: "index_solid_queue_ready_executions_on_job_id", unique: true
    t.index ["queue_name", "priority", "job_id"], name: "index_solid_queue_ready_executions_for_dispatch"
  end

  create_table "solid_queue_scheduled_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "job_id", null: false
    t.integer "priority", default: 0, null: false
    t.string "queue_name", null: false
    t.datetime "scheduled_at", null: false
    t.index ["job_id"], name: "index_solid_queue_scheduled_executions_on_job_id", unique: true
    t.index ["scheduled_at", "priority", "job_id"], name: "index_solid_queue_scheduled_executions_for_alerting"
  end

  create_table "technicians", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.bigint "company_id", null: false
    t.datetime "created_at", null: false
    t.string "email"
    t.string "name", null: false
    t.text "notes"
    t.string "phone", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["company_id", "name"], name: "index_technicians_on_company_id_and_name", unique: true
    t.index ["company_id"], name: "index_technicians_on_company_id"
    t.index ["user_id"], name: "index_technicians_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.string "company_id"
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "name"
    t.boolean "password_change_required", default: false
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
  add_foreign_key "technicians", "companies"
  add_foreign_key "technicians", "users", on_delete: :nullify
end
