class RemoveBidIdFromCategories < ActiveRecord::Migration
  def up
    remove_index :categories, :bid_id
    remove_column :categories, :bid_id
  end

  def down
    add_column :categories, :bid_id, :integer
    add_index :categories, :bid_id
  end
end
