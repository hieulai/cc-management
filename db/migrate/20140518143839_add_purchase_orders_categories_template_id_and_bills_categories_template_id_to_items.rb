class AddPurchaseOrdersCategoriesTemplateIdAndBillsCategoriesTemplateIdToItems < ActiveRecord::Migration
  def change
    add_column :items, :purchase_orders_categories_template_id, :integer
    add_column :items, :bills_categories_template_id, :integer

    add_index :items, :purchase_orders_categories_template_id
    add_index :items, :bills_categories_template_id
  end
end
