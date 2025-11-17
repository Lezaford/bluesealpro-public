class AddCsvFieldsToCustomers < ActiveRecord::Migration[8.1]
  def change
    change_table :customers, bulk: true do |t|
      #
      # Core fields your app expects
      #
      t.string :first_name
      t.string :last_name
      t.string :address1
      t.string :address2
      t.string :city
      t.string :state
      t.string :zip

      #
      # CSV / CRM-specific fields
      #
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
      # NOTE: we do NOT add :notes here – it already exists
      t.string
