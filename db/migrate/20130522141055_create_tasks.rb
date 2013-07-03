class CreateTasks < ActiveRecord::Migration
  def change
    create_table :tasks do |t|
      t.references :tasklist
      t.string "name"
      t.boolean "completed"
      t.integer "time_to_complete"
      t.string "department"
      t.timestamps
    end
    add_index :tasks, :tasklist_id
  end
end
