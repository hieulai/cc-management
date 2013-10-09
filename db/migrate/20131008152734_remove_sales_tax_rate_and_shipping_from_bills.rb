class RemoveSalesTaxRateAndShippingFromBills < ActiveRecord::Migration
  def up
    remove_column :bills, :sales_tax_rate
    remove_column :bills, :shipping
  end

  def down
    add_column :bills, :sales_tax_rate, :scale => 4, :precision => 10
    add_column :bills, :shipping, :scale => 2, :precision => 10
  end
end
