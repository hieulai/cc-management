class RemoveObsoleteFields < ActiveRecord::Migration
  def up
    remove_column :bills, :categories_template_id
    remove_column :bills, :reconciled
    remove_column :bills, :vendor_id
    remove_column :bills_items, :bill_id

    remove_column :purchase_orders, :categories_template_id
    remove_column :purchase_orders_items, :purchase_order_id

    remove_column :deposits, :reconciled
    remove_column :invoices, :reconciled
    remove_column :invoices_bills, :reconciled
    remove_column :payments, :reconciled
    remove_column :receipts, :reconciled
    remove_column :transfers, :reconciled
    remove_column :un_job_costed_items, :reconciled
    remove_column :receipts_items, :reconciled

    remove_column :items, :bill_id
    remove_column :items, :purchase_order_id
  end

  def down
    add_column :bills, :categories_template_id, :integer
    add_column :bills, :reconciled, :boolean
    add_column :bills, :vendor_id, :integer
    add_column :bills_items, :bill_id, :integer

    add_column :purchase_orders, :categories_template_id, :integer
    add_column :purchase_orders_items, :purchase_order_id, :integer

    add_column :deposits, :reconciled, :boolean
    add_column :invoices, :reconciled, :boolean
    add_column :invoices_bills, :reconciled, :boolean
    add_column :payments, :reconciled, :boolean
    add_column :receipts, :reconciled, :boolean
    add_column :transfers, :reconciled, :boolean
    add_column :un_job_costed_items, :reconciled, :boolean
    add_column :receipts_items, :reconciled, :boolean

    add_column :items, :bill_id, :integer
    add_column :items, :purchase_order_id, :integer
  end
end
