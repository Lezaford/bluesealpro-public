class AddUniqueIndexToBetaRequestsEmail < ActiveRecord::Migration[7.1]
  def change
    add_index :beta_requests, :email, unique: true
  end
end
