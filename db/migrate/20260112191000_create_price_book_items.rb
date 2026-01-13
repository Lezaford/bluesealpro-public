class CreatePriceBookItems < ActiveRecord::Migration[8.1]
  def change
    create_table :price_book_items do |t|
      t.references :company, null: false, foreign_key: true
      t.string :name, null: false
      t.string :category, null: false, default: "materials"
      t.integer :unit_price_cents, null: false, default: 0
      t.boolean :taxable, default: true
      t.boolean :active, default: true
      t.string :lock_policy, default: "admin_only"

      t.timestamps
    end

    add_index :price_book_items, [ :company_id, :active ]
  end
end
