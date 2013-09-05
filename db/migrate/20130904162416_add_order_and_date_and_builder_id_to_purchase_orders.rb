class AddOrderAndDateAndBuilderIdToPurchaseOrders < ActiveRecord::Migration
  def change
    add_column :purchase_orders, :number, :integer
    add_column :purchase_orders, :date, :datetime
    add_column :purchase_orders, :builder_id, :integer
    add_index :purchase_orders, :builder_id
  end
end
