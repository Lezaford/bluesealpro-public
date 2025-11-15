class CreateJobs < ActiveRecord::Migration[8.1]
  def change
    create_table :jobs do |t|
      t.references :company, null: false, foreign_key: true
      t.references :customer, null: false, foreign_key: true
      t.integer :technician_id
      t.datetime :starts_at
      t.string :status
      t.text :notes
      t.string :model_number
      t.string :serial_number
      t.text :complaint
      t.text :diagnosis
      t.text :work_performed

      t.timestamps
    end
  end
end
