class RemovePaymentIdFromBills < ActiveRecord::Migration
  def up
    remove_index :bills, :payment_id
    remove_column :bills, :payment_id
  end

  def down
    add_column :bills, :payment_id, :integer
    add_index :bills, :payment_id
  end
end
