class CreateSpecifications < ActiveRecord::Migration
  def change
    create_table :specifications do |t|
      t.references :project
      t.string "name"
      t.string "description"
      t.boolean "completed"
      t.timestamps
    end
    add_index :specifications, :project_id
  end
end
