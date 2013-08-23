class ChangeAmountToTextOnBids < ActiveRecord::Migration
  def up
    change_column :bids, :amount, :text
  end

  def down
    change_column :bids, :amount, :decimal, :scale => 2, :precision => 10
  end
end
