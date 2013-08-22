class AddSpecificationIdToCategory < ActiveRecord::Migration
  def change
    add_column :categories, :specification_id, :integer
    add_index :categories, :specification_id
  end
end
