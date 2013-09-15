class RenameSalesTaxToSalesTaxRateOfPurchaseOrders < ActiveRecord::Migration
  def up
    rename_column :purchase_orders, :sales_tax, :sales_tax_rate
    change_column :purchase_orders, :sales_tax_rate, :decimal, :scale => 4, :precision => 10
  end

  def down
    change_column :purchase_orders, :sales_tax_rate, :decimal, :scale => 2, :precision => 10
    rename_column :purchase_orders, :sales_tax_rate, :sales_tax
  end
end
