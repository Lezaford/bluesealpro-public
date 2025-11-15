class CreateLineItems < ActiveRecord::Migration[8.1]
  def change
    create_table :line_items do |t|
      t.references :invoice, null: false, foreign_key: true
      t.string :item_type
      t.string :description
      t.decimal :amount, precision: 10, scale: 2

      t.timestamps
    end
  end
end
