class AddTaxRateToCompanies < ActiveRecord::Migration[8.1]
  def change
    add_column :companies, :tax_rate, :decimal, precision: 5, scale: 4, default: 0.0
  end
end
