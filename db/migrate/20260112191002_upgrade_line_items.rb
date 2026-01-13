class UpgradeLineItems < ActiveRecord::Migration[8.1]
  def change
    add_column :line_items, :company_id, :bigint
    add_column :line_items, :price_book_item_id, :bigint
    add_column :line_items, :quantity, :decimal, precision: 10, scale: 2, default: 1
    add_column :line_items, :unit_price_cents, :integer, default: 0
    add_column :line_items, :taxable, :boolean, default: true
    add_column :line_items, :locked, :boolean, default: false
    add_column :line_items, :position, :integer

    # Backfill unit_price_cents from amount if amount exists
    reversible do |dir|
      dir.up do
        # Backfill: amount * 100 -> unit_price_cents, quantity = 1
        execute <<-SQL
          UPDATE line_items
          SET unit_price_cents = COALESCE(amount * 100, 0), quantity = 1
          WHERE amount IS NOT NULL
        SQL
      end
    end

    # Rename item_type to category for consistency
    rename_column :line_items, :item_type, :category

    add_foreign_key :line_items, :companies
    add_foreign_key :line_items, :price_book_items
    add_index :line_items, :invoice_id
    add_index :line_items, :company_id
    add_index :line_items, :price_book_item_id
  end
end
