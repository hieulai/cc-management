class CreateTasklists < ActiveRecord::Migration
  def change
    create_table :tasklists do |t|
      t.references :builder
      t.references :project
      t.string "name"
      t.integer "completed"
      t.integer "total"
      t.boolean "default"
      t.timestamps
    end
    add_index :tasklists, :builder_id
    add_index :tasklists, :project_id
  end
end
