class AddPaymentIdToBills < ActiveRecord::Migration
  def change
    add_column :bills, :payment_id, :integer
    add_index :bills, :payment_id
  end
end
