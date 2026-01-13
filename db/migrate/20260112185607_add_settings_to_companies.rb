class AddSettingsToCompanies < ActiveRecord::Migration[8.1]
  def change
    add_column :companies, :phone, :string
    add_column :companies, :email, :string
    add_column :companies, :ein, :string
    add_column :companies, :website_url, :string
    add_column :companies, :address_line1, :string
    add_column :companies, :address_line2, :string
    add_column :companies, :city, :string
    add_column :companies, :state, :string
    add_column :companies, :zip, :string
    add_column :companies, :time_zone, :string, default: "America/New_York"
  end
end
