class CreateProjects < ActiveRecord::Migration
  def change
    create_table :projects do |t|
      t.references :client
      t.string  "name"
      t.string  "project_type"
      t.string  "status", :default => "Current Lead"
      t.string  "lead_stage"
      t.decimal "progress"
      t.integer "revenue"
      t.date    "start_date"
      t.date    "completion_date"
      t.date    "deadline"
      t.integer "schedule_variance"
      t.string  "next_tasks"
      t.text    "lead_notes"
      t.text    "project_notes"
      t.timestamps
    end
    add_index :projects, :client_id
  end

end
