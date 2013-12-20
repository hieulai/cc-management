class CleanupAmountInBillsAndPurchaseOrders < ActiveRecord::Migration
  def up
    PurchaseOrder.where('amount is not null').each do |po|
      po.amount.each do |i|
        if Item.exists?(i[:id])
          item = Item.find(i[:id])
          updated_cost = item.actual_cost.to_f - i[:actual_cost].to_f
          item.update_attribute(:actual_cost, updated_cost == 0 ? nil : updated_cost)
        end
      end
    end
    Bill.where('purchase_order_id is null and amount is not null').each do |b|
      b.amount.each do |i|
        if Item.exists?(i[:id])
          item = Item.find(i[:id])
          updated_cost = item.actual_cost.to_f - i[:actual_cost].to_f
          item.update_attribute(:actual_cost, updated_cost == 0 ? nil : updated_cost)
        end
      end
    end
  end

  def down
  end
end
