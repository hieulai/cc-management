class AddSalesTaxAndShippingToPurchaseOrders < ActiveRecord::Migration
  def change
    add_column :purchase_orders, :sales_tax, :decimal, :scale => 2, :precision => 10
    add_column :purchase_orders, :shipping, :decimal, :scale => 2, :precision => 10
  end
end
