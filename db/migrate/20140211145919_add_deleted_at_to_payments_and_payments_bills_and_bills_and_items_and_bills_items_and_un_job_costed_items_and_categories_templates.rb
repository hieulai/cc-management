class AddDeletedAtToPaymentsAndPaymentsBillsAndBillsAndItemsAndBillsItemsAndUnJobCostedItemsAndCategoriesTemplates < ActiveRecord::Migration
  def change
    add_column :payments, :deleted_at, :time
    add_column :payments_bills, :deleted_at, :time
    add_column :bills, :deleted_at, :time
    add_column :items, :deleted_at, :time
    add_column :bills_items, :deleted_at, :time
    add_column :un_job_costed_items, :deleted_at, :time
    add_column :categories_templates, :deleted_at, :time
  end
end
