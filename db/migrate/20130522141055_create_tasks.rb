class CreateTasks < ActiveRecord::Migration
  def change
    create_table :tasks do |t|
      t.integer "name"
      t.boolean "completed"
      t.integer "time_to_complete"
      t.string "department"
      t.timestamps
    end
  end
end
