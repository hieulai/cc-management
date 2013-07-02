class CreateTasklists < ActiveRecord::Migration
  def change
    create_table :tasklists do |t|
      t.string "name"
      t.integer "completed"
      t.integer "total"
      t.boolean "default"
      t.timestamps
    end
  end
end
