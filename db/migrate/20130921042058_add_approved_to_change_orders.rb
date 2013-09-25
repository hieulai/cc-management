class AddApprovedToChangeOrders < ActiveRecord::Migration
  def change
    add_column :change_orders, :approved, :boolean
  end
end
