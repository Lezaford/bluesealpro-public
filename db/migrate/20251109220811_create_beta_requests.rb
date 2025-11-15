class CreateBetaRequests < ActiveRecord::Migration[8.1]
  def change
    create_table :beta_requests do |t|
      t.string :name
      t.string :email
      t.string :company
      t.string :phone
      t.text :message
      t.inet :ip
      t.text :user_agent

      t.timestamps
    end
  end
end
