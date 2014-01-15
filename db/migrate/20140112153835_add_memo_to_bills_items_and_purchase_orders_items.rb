class AddMemoToBillsItemsAndPurchaseOrdersItems < ActiveRecord::Migration
  def change
    add_column :bills_items, :memo, :text
    add_column :purchase_orders_items, :memo, :text
  end
end
