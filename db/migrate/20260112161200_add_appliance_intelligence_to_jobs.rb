class AddApplianceIntelligenceToJobs < ActiveRecord::Migration[7.1]
  def change
    add_column :jobs, :appliance_type, :string
    add_column :jobs, :brand, :string
  end
end
