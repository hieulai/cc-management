class AddCreditAmountToReceipts < ActiveRecord::Migration
  def change
    add_column :receipts, :credit_amount, :decimal, :precision => 10, :scale => 2
  end
end
