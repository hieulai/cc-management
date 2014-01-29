class AddPayorToReceipts < ActiveRecord::Migration
  def change
    add_column :receipts, :payor, :string
  end
end
