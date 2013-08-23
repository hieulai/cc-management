class AddVendorIdToBids < ActiveRecord::Migration
  def change
    add_column :bids, :vendor_id, :integer
    add_index :bids, :vendor_id
  end
end
