class AddDurationMinutesToJobs < ActiveRecord::Migration[8.1]
  def change
    add_column :jobs, :duration_minutes, :integer, default: 60
  end
end
