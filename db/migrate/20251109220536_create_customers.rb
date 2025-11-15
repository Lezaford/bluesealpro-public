class CreateCustomers < ActiveRecord::Migration[8.1]
  def change
    create_table :customers do |t|
      t.references :company, null: false, foreign_key: true
      t.string :name
      t.string :phone
      t.string :email
      t.string :address
      t.text :notes

      t.timestamps
    end
  end
end
