class RemoveNumberFromPurchaseOrder < ActiveRecord::Migration
  def up
    remove_column :purchase_orders, :number
  end

  def down
    add_column :purchase_orders, :number, :integer
  end
end
