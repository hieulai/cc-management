class RemoveCategoriesTemplateIdAndCostAndDescriptionAndMarginAndQtyAndUnitFromChangeOrders < ActiveRecord::Migration
  def up
    remove_column :change_orders, :cost
    remove_column :change_orders, :description
    remove_column :change_orders, :qty
    remove_column :change_orders, :margin
    remove_column :change_orders, :unit
    remove_index :change_orders, :categories_template_id
    remove_column :change_orders, :categories_template_id
  end

  def down
    add_column :change_orders, :cost, :decimal, :scale => 2, :precision => 10
    add_column :change_orders, :description, :string
    add_column :change_orders, :qty, :decimal, :scale => 2, :precision => 10
    add_column :change_orders, :margin, :decimal, :scale => 2, :precision => 10
    add_column :change_orders, :unit, :string
    add_column :change_orders, :categories_template_id, :string
    add_index :change_orders, :categories_template_id
  end
end
