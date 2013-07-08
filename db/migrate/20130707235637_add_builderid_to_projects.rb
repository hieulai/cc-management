class AddBuilderidToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :builder_id, :integer
    add_index :projects, :builder_id
  end
end
