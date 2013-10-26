class AddBidIdToBills < ActiveRecord::Migration
  def change
    add_column :bills, :bid_id, :integer
    add_index :bills, :bid_id
  end
end
