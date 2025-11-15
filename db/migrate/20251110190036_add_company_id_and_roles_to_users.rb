class AddCompanyIdAndRolesToUsers < ActiveRecord::Migration[8.1]
  def change
    # DO NOT re-add company_id, it already exists
    # So REMOVE this line if it exists:
    # add_reference :users, :company

    # Only add role if missing:
    add_column :users, :role, :integer, default: 2, null: false unless column_exists?(:users, :role)
  end
end
