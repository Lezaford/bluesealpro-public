class AddInvoiceConstraints < ActiveRecord::Migration[8.1]
  def change
    add_index :invoices, :job_id, unique: true, if_not_exists: true
    add_index :invoices, :company_id, if_not_exists: true
  end
end
