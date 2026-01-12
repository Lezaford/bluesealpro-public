class AddCustomerSearchIndexes < ActiveRecord::Migration[7.1]
  def change
    # Index on first_name for faster search queries
    unless index_exists?(:customers, :first_name)
      add_index :customers, :first_name
    end

    # Index on last_name for faster search queries
    unless index_exists?(:customers, :last_name)
      add_index :customers, :last_name
    end

    # Index on display_name for faster search queries (already indexed in schema)
    # Verify it exists or add if missing
    unless index_exists?(:customers, :display_name)
      add_index :customers, :display_name
    end

    # Index on phone for search performance
    unless index_exists?(:customers, :phone)
      add_index :customers, :phone
    end

    # Index on mobile_number for search performance
    unless index_exists?(:customers, :mobile_number)
      add_index :customers, :mobile_number
    end

    # Compound index for tenant-scoped first_name searches
    unless index_exists?(:customers, [ :company_id, :first_name ])
      add_index :customers, [ :company_id, :first_name ], name: "index_customers_on_company_id_and_first_name"
    end

    # Compound index for tenant-scoped last_name searches
    unless index_exists?(:customers, [ :company_id, :last_name ])
      add_index :customers, [ :company_id, :last_name ], name: "index_customers_on_company_id_and_last_name"
    end

    # Compound index for tenant-scoped email searches (if not exists)
    unless index_exists?(:customers, [ :company_id, :email ])
      add_index :customers, [ :company_id, :email ], name: "index_customers_on_company_id_and_email"
    end
  end
end
