class CreatePurchaseOrders < ActiveRecord::Migration
  def change
    create_table :purchase_orders do |t|
      t.references :project
      t.references :vendor
      t.references :categories_template
      t.text :amount
      t.text :notes
      t.boolean :chosen

      t.timestamps
    end

    add_index :purchase_orders, :project_id
    add_index :purchase_orders, :vendor_id
    add_index :purchase_orders, :categories_template_id
  end
end
