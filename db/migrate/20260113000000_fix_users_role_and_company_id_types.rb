# The original users migration created role and company_id as strings, but the User model
# uses an integer enum (owner/admin/tech/viewer) and company_id is a belongs_to FK.
class FixUsersRoleAndCompanyIdTypes < ActiveRecord::Migration[8.1]
  def up
    # Map any legacy string roles to the enum integers; unknown values become tech (2).
    change_column :users, :role, :integer, default: 2, null: false, using: <<~SQL.squish
      CASE role WHEN 'owner' THEN 0 WHEN 'admin' THEN 1 WHEN 'tech' THEN 2 WHEN 'viewer' THEN 3 ELSE 2 END
    SQL
    # Users without a company cannot satisfy belongs_to :company (required), but the column stays nullable for legacy rows.
    change_column :users, :company_id, :bigint, using: "NULLIF(company_id, '')::bigint"
    add_index :users, :company_id unless index_exists?(:users, :company_id)
    add_foreign_key :users, :companies unless foreign_key_exists?(:users, :companies)
  end

  def down
    remove_foreign_key :users, :companies if foreign_key_exists?(:users, :companies)
    change_column :users, :company_id, :string, using: "company_id::text"
    change_column :users, :role, :string, default: nil, null: true, using: "role::text"
  end
end
