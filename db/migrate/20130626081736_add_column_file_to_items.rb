class AddColumnFileToItems < ActiveRecord::Migration
  def change
    add_column :items, :file, :string
  end
end
