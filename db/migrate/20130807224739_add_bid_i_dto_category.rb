class AddBidIDtoCategory < ActiveRecord::Migration
  def change
    add_column :categories, :bid_id, :integer
    add_index :categories, :bid_id
  end
  
end
