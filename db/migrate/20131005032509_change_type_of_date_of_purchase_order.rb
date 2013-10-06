class ChangeTypeOfDateOfPurchaseOrder < ActiveRecord::Migration
  def up
    change_column :purchase_orders, :date, :date
  end

  def down
    change_column :purchase_orders, :date, :datetime
  end
end
