class RenamePaidAmountToAmountOfPaymentsBill < ActiveRecord::Migration
  def up
    rename_column :payments_bills, :paid_amount, :amount
  end

  def down
    rename_column :payments_bills, :amount, :paid_amount
  end
end
