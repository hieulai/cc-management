class AddRemainingAmountToReceipt < ActiveRecord::Migration
  def change
    add_column :receipts, :remaining_amount, :decimal, :scale => 2, :precision => 10
  end
end
