class AddPurchaseOrdersCategoriesTemplateIdToPurchaseOrdersItems < ActiveRecord::Migration
  def change
    add_column :purchase_orders_items, :purchase_orders_categories_template_id, :integer
    add_index :purchase_orders_items, :purchase_orders_categories_template_id, :name => :index_pos_items_on_pos_ct_id
  end
end
