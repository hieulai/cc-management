class AddPayerIdAndPayerTypeToPurchaseOrders < ActiveRecord::Migration
  def change
    add_column :purchase_orders, :payer_id, :integer
    add_column :purchase_orders, :payer_type, :string

    PurchaseOrder.all.each do |po|
      po.update_column(:payer_id, po.vendor_id)
      po.update_column(:payer_type, Vendor.name)
    end
  end
end
