class AddCsvFieldsToCustomers < ActiveRecord::Migration[8.1]
  def change
    change_table :customers, bulk: true do |t|
      t.string  :display_name
      t.string  :mobile_number
      t.string  :home_number
      t.text    :additional_emails
      t.string  :company_name
      t.string  :role
      t.string  :work_number
      t.string  :bills_to
      t.string  :accepts_bills_from
      t.string  :tags
      t.text    :notes
      t.string  :external_id
      t.string  :customer_type
      t.boolean :customer_notifications_enabled, default: true, null: false
      t.boolean :customer_is_contractor, default: false, null: false
      t.string  :lead_source
      t.datetime :customer_created_at
      t.date    :last_service_date
      t.decimal :lifetime_value, precision: 12, scale: 2, default: 0

      # address 1
      t.string  :address_1_street_line_1
      t.string  :address_1_street_line_2
      t.string  :address_1_city
      t.string  :address_1_state
      t.string  :address_1_postal_code
      t.boolean :address_1_billing, default: true
      t.text    :address_1_notes

      # address 2
      t.string  :address_2_street_line_1
      t.string  :address_2_street_line_2
      t.string  :address_2_city
      t.string  :address_2_state
      t.string  :address_2_postal_code
      t.boolean :address_2_billing, default: false
      t.text    :address_2_notes

      # address 3
      t.string  :address_3_street_line_1
      t.string  :address_3_street_line_2
      t.string  :address_3_city
      t.string  :address_3_state
      t.string  :address_3_postal_code
      t.boolean :address_3_billing, default: false
      t.text    :address_3_notes

      # address 4
      t.string  :address_4_street_line_1
      t.string  :address_4_street_line_2
      t.string  :address_4_city
      t.string  :address_4_state
      t.string  :address_4_postal_code
      t.boolean :address_4_billing, default: false
      t.text    :address_4_notes
    end

    add_index :customers, :external_id, unique: true
    add_index :customers, :display_name
    add_index :customers, :email unless index_exists?(:customers, :email)
  end
end
