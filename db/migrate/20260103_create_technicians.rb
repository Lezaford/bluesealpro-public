class CreateTechnicians < ActiveRecord::Migration[8.1]
  def change
    create_table :technicians do |t|
      t.references :company, null: false, foreign_key: true
      t.string :name, null: false
      t.string :phone, null: false
      t.string :email
      t.text :notes
      t.boolean :active, default: true, null: false

      t.timestamps
    end

    add_index :technicians, [ :company_id, :name ], unique: true
  end
end
