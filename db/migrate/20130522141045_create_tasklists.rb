class CreateTasklists < ActiveRecord::Migration
  def change
    create_table :tasklists do |t|
      t.references :builder
      t.string "name"
      t.integer "completed"
      t.integer "total"
      t.boolean "default"
      t.timestamps
    end
    add_index :tasklists, :builder_id
  end
end
