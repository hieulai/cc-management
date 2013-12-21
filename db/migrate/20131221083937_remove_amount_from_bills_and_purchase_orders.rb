class RemoveAmountFromBillsAndPurchaseOrders < ActiveRecord::Migration
  def up
    remove_column :bills, :amount
    remove_column :purchase_orders, :amount
  end

  def down
    add_column :bills, :amount, :text
    add_column :purchase_orders, :amount, :text
  end
end
