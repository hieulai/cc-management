class AddChangeOrderAndClientBilledToItems < ActiveRecord::Migration
  def change
    add_column :items, :change_order, :boolean, :null => false, :default => false
    add_column :items, :client_billed, :boolean, :null => false, :default => false
  end
end
