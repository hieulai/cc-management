class CreateChangeOrdersCategories < ActiveRecord::Migration
  def change
    create_table :change_orders_categories do |t|
      t.references :change_order
      t.references :category

      t.timestamps
    end
    add_index :change_orders_categories, :change_order_id
    add_index :change_orders_categories, :category_id
  end
end
