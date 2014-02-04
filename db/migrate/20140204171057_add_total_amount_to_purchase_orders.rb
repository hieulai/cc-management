class AddTotalAmountToPurchaseOrders < ActiveRecord::Migration
  def change
    add_column :purchase_orders, :cached_total_amount, :decimal, :precision => 10, :scale => 2

    PurchaseOrder.all.each do |po|
      po.update_column(:cached_total_amount, po.total_amount)
    end
  end
end
