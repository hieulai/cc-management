class CreatePurchaseOrdersCategoriesTemplates < ActiveRecord::Migration
  def change
    create_table :purchase_orders_categories_templates do |t|
      t.references :purchase_order
      t.references :categories_template
      t.timestamps
    end

    add_index :purchase_orders_categories_templates, :purchase_order_id, :name => :index_pos_cts_on_purchase_order_id
    add_index :purchase_orders_categories_templates, :categories_template_id, :name => :index_pos_cts_on_categories_template_id
  end
end
