class AddUserIdToTechnicians < ActiveRecord::Migration[8.1]
  def change
    add_column :technicians, :user_id, :bigint
    add_foreign_key :technicians, :users, on_delete: :nullify
  end
end
