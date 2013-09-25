class AddChangeOrdersCategoryIdToItems < ActiveRecord::Migration
  def change
    add_column :items, :change_orders_category_id, :integer
    add_index :items, :change_orders_category_id
  end
end
