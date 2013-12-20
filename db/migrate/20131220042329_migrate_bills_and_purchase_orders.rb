class MigrateBillsAndPurchaseOrders < ActiveRecord::Migration
  def up
    PurchaseOrder.skip_callback(:create)
    PurchaseOrder.where('amount is not null').each do |po|
      po.amount.each do |i|
        next unless i['id'] && Item.exists?(i['id'])

        po.purchase_orders_items.create(:item_id => i['id'],
                                        :description => i['description'],
                                        :qty => i['qty'],
                                        :estimated_cost => i['estimated_cost'],
                                        :actual_cost => i['actual_cost'])
      end
    end
    PurchaseOrder.set_callback(:create)

    Bill.skip_callback(:create)
    Bill.where('purchase_order_id is null and amount is not null').each do |b|
      b.amount.each do |i|
        next unless i['id'] && Item.exists?(i['id'])
        b.bills_items.create(:item_id => i['id'],
                              :description => i['description'],
                              :qty => i['qty'].to_f,
                              :estimated_cost => i['estimated_cost'].to_f,
                              :actual_cost => i['actual_cost'].to_f)
      end
    end
    Bill.set_callback(:create)
  end

  def down
  end
end
