class RemoveBidIdFromVendors < ActiveRecord::Migration
  def up
    remove_index :vendors, :bid_id
    remove_column :vendors, :bid_id
  end

  def down
    add_column :vendors, :bid_id, :integer
    add_index :vendors, :bid_id
  end
end
