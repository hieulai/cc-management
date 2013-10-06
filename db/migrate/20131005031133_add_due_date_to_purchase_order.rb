class AddDueDateToPurchaseOrder < ActiveRecord::Migration
  def change
    add_column :purchase_orders, :due_date, :date
  end
end
