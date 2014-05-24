class MigrateMultipleCategoriesBills < ActiveRecord::Migration
  def up
    PurchaseOrder.where('categories_template_id is NOT NULL').each do |po|
      next unless po.categories_template
      po_ct = po.purchase_orders_categories_templates.create(:categories_template_id => po.categories_template_id)
      po.purchase_orders_items.each do |pi|
        pi.update_column(:purchase_orders_categories_template_id, po_ct.id)
      end
      po.items.each do |i|
        i.update_column(:purchase_orders_categories_template_id, po_ct.id)
      end
    end

    Bill.where('categories_template_id is NOT NULL AND purchase_order_id IS NULL').each do |b|
      next unless b.categories_template
      b_ct = b.bills_categories_templates.create(:categories_template_id => b.categories_template_id)
      b.bills_items.each do |bi|
        bi.update_column(:bills_categories_template_id, b_ct.id)
      end
      b.items.each do |i|
        i.update_column(:bills_categories_template_id, b_ct.id)
      end
    end
  end

  def down
  end
end
