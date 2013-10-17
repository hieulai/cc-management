class AddRemainingAmountToBills < ActiveRecord::Migration
  def change
    add_column :bills, :remaining_amount, :decimal, :scale => 2, :precision => 10
  end
end
