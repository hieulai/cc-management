class MigrateMultipleCategoriesBills < ActiveRecord::Migration
  def up
    PurchaseOrder.where('categories_template_id is NOT NULL').each do |po|
      next unless po.categories_template
      po.update_column(:cached_total_amount, 0)
      po_ct = po.purchase_orders_categories_templates.new(:categories_template_id => po.categories_template_id)
      po_ct.purchase_orders_items = po.purchase_orders_items
      po_ct.items = po.items
      po_ct.save
    end

    Bill.where('categories_template_id is NOT NULL AND purchase_order_id IS NULL').each do |b|
      next unless b.categories_template
      b.update_column(:cached_total_amount, 0)
      b.accounting_transactions.where(account_id: b.categories_template.cogs_account.id).destroy_all
      b_ct = b.bills_categories_templates.new(:categories_template_id => b.categories_template_id)
      b_ct.bills_items = b.bills_items
      b_ct.items = b.items
      b_ct.save
    end
  end

  def down
  end
end
