class RemoveAmountFromPayments < ActiveRecord::Migration
  def up
    remove_column :payments, :amount
  end

  def down
    add_column :payments, :amount, :decimal, :scale => 2, :precision => 12
  end
end
