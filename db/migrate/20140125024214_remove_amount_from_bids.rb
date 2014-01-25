class RemoveAmountFromBids < ActiveRecord::Migration
  def up
    remove_column :bids, :amount
  end

  def down
    add_column :bids, :amount, :text
  end
end
