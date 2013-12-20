class CreatePurchaseOrdersItems < ActiveRecord::Migration
  def change
    create_table :purchase_orders_items do |t|
      t.references :purchase_order
      t.references :item

      t.string :description
      t.decimal :qty, :precision => 10, :scale => 2
      t.decimal :amount, :precision => 10, :scale => 2
      t.decimal :estimated_cost, :precision => 10, :scale => 2
      t.decimal :actual_cost, :precision => 10, :scale => 2

      t.timestamps
    end
  end
end
