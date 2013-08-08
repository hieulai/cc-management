class AddBidIDtoVendor < ActiveRecord::Migration
  def change
    add_column :vendors, :bid_id, :integer
    add_index :vendors, :bid_id
  end
  
end
