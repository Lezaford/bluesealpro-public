class CreateCompanies < ActiveRecord::Migration[8.1]
  def change
    create_table :companies do |t|
      t.string :name
      t.string :address
      t.string :logo

      t.timestamps
    end
  end
end
