class UpgradeLineItems < ActiveRecord::Migration[8.1]
  def change
    add_column :line_items, :company_id, :bigint unless column_exists?(:line_items, :company_id)
    add_column :line_items, :price_book_item_id, :bigint unless column_exists?(:line_items, :price_book_item_id)
    add_column :line_items, :quantity, :decimal, precision: 10, scale: 2, default: 1 unless column_exists?(:line_items, :quantity)
    add_column :line_items, :unit_price_cents, :integer, default: 0 unless column_exists?(:line_items, :unit_price_cents)
    add_column :line_items, :taxable, :boolean, default: true unless column_exists?(:line_items, :taxable)
    add_column :line_items, :locked, :boolean, default: false unless column_exists?(:line_items, :locked)
    add_column :line_items, :position, :integer unless column_exists?(:line_items, :position)

    reversible do |dir|
      dir.up do
        if column_exists?(:line_items, :amount) && column_exists?(:line_items, :unit_price_cents)
          execute <<-SQL
            UPDATE line_items
            SET unit_price_cents = COALESCE(amount * 100, 0), quantity = 1
            WHERE amount IS NOT NULL
          SQL
        end
      end
    end

    # Rename item_type -> category only if it hasn't already been renamed
    if column_exists?(:line_items, :item_type) && !column_exists?(:line_items, :category)
      rename_column :line_items, :item_type, :category
    end

    add_foreign_key :line_items, :companies unless foreign_key_exists?(:line_items, :companies)
    add_foreign_key :line_items, :price_book_items unless foreign_key_exists?(:line_items, :price_book_items)

    add_index :line_items, :invoice_id, if_not_exists: true
    add_index :line_items, :company_id, if_not_exists: true
    add_index :line_items, :price_book_item_id, if_not_exists: true
  end
end
