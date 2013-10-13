class RemovePaidFromBills < ActiveRecord::Migration
  def up
    remove_column :bills, :paid
  end

  def down
    add_column :bills, :paid, :boolean
  end
end
