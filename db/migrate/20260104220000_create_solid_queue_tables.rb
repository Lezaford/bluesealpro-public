class CreateSolidQueueTables < ActiveRecord::Migration[8.1]
  def up
    # This migration creates all Solid Queue tables by loading the queue schema
    # The queue_schema.rb file should already exist and contain the full schema definition
    unless table_exists?(:solid_queue_jobs)
      create_table :solid_queue_jobs, force: :cascade do |t|
        t.string :queue_name, null: false
        t.string :class_name, null: false
        t.text :arguments
        t.integer :priority, default: 0, null: false
        t.string :active_job_id
        t.datetime :scheduled_at
        t.datetime :finished_at
        t.string :concurrency_key
        t.datetime :created_at, null: false
        t.datetime :updated_at, null: false
      end
      add_index :solid_queue_jobs, :active_job_id
      add_index :solid_queue_jobs, :class_name
      add_index :solid_queue_jobs, :finished_at
      add_index :solid_queue_jobs, [ :queue_name, :finished_at ], name: "index_solid_queue_jobs_for_filtering"
      add_index :solid_queue_jobs, [ :scheduled_at, :finished_at ], name: "index_solid_queue_jobs_for_alerting"
    end

    unless table_exists?(:solid_queue_claimed_executions)
      create_table :solid_queue_claimed_executions, force: :cascade do |t|
        t.bigint :job_id, null: false
        t.bigint :process_id
        t.datetime :created_at, null: false
      end
      add_index :solid_queue_claimed_executions, :job_id, unique: true
      add_index :solid_queue_claimed_executions, [ :process_id, :job_id ], name: "index_solid_queue_claimed_executions_on_process_id_and_job_id"
    end

    unless table_exists?(:solid_queue_failed_executions)
      create_table :solid_queue_failed_executions, force: :cascade do |t|
        t.bigint :job_id, null: false
        t.text :error
        t.datetime :created_at, null: false
      end
      add_index :solid_queue_failed_executions, :job_id, unique: true
    end

    unless table_exists?(:solid_queue_blocked_executions)
      create_table :solid_queue_blocked_executions, force: :cascade do |t|
        t.bigint :job_id, null: false
        t.string :queue_name, null: false
        t.integer :priority, default: 0, null: false
        t.string :concurrency_key, null: false
        t.datetime :expires_at, null: false
        t.datetime :created_at, null: false
      end
      add_index :solid_queue_blocked_executions, [ :concurrency_key, :priority, :job_id ], name: "index_solid_queue_blocked_executions_for_release"
      add_index :solid_queue_blocked_executions, [ :expires_at, :concurrency_key ], name: "index_solid_queue_blocked_executions_for_maintenance"
      add_index :solid_queue_blocked_executions, :job_id, unique: true, name: "index_solid_queue_blocked_executions_on_job_id"
    end

    unless table_exists?(:solid_queue_pauses)
      create_table :solid_queue_pauses, force: :cascade do |t|
        t.string :queue_name, null: false
        t.datetime :created_at, null: false
      end
      add_index :solid_queue_pauses, :queue_name, unique: true, name: "index_solid_queue_pauses_on_queue_name"
    end

    unless table_exists?(:solid_queue_processes)
      create_table :solid_queue_processes, force: :cascade do |t|
        t.string :kind, null: false
        t.string :name, null: false
        t.string :hostname, null: false
        t.integer :pid, null: false
        t.datetime :created_at, null: false
      end
      add_index :solid_queue_processes, [ :hostname, :pid ], unique: true, name: "index_solid_queue_processes_on_hostname_and_pid"
    end

    unless table_exists?(:solid_queue_ready_executions)
      create_table :solid_queue_ready_executions, force: :cascade do |t|
        t.bigint :job_id, null: false
        t.string :queue_name, null: false
        t.integer :priority, default: 0, null: false
        t.datetime :created_at, null: false
      end
      add_index :solid_queue_ready_executions, [ :queue_name, :priority, :job_id ], name: "index_solid_queue_ready_executions_for_dispatch"
      add_index :solid_queue_ready_executions, :job_id, unique: true, name: "index_solid_queue_ready_executions_on_job_id"
    end

    unless table_exists?(:solid_queue_scheduled_executions)
      create_table :solid_queue_scheduled_executions, force: :cascade do |t|
        t.bigint :job_id, null: false
        t.string :queue_name, null: false
        t.integer :priority, default: 0, null: false
        t.datetime :scheduled_at, null: false
        t.datetime :created_at, null: false
      end
      add_index :solid_queue_scheduled_executions, [ :scheduled_at, :priority, :job_id ], name: "index_solid_queue_scheduled_executions_for_alerting"
      add_index :solid_queue_scheduled_executions, :job_id, unique: true, name: "index_solid_queue_scheduled_executions_on_job_id"
    end
  end

  def down
    # Drop all Solid Queue tables
    [ :solid_queue_scheduled_executions, :solid_queue_ready_executions, :solid_queue_processes,
     :solid_queue_pauses, :solid_queue_blocked_executions, :solid_queue_failed_executions,
     :solid_queue_claimed_executions, :solid_queue_jobs ].each do |table_name|
      drop_table table_name, if_exists: true
    end
  end
end
