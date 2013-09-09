class AddPurchaseOrderIdToItem < ActiveRecord::Migration
  def change
    add_column :items, :purchase_order_id, :integer
    add_index :items, :purchase_order_id
  end
end
