class MigrateDepositsReceiptAmounts < ActiveRecord::Migration
  def up
    DepositsReceipt.all.each do |dr|
      dr.deposit.builder.deposits_held_account.update_attribute(:balance, dr.deposit.builder.deposits_held_account.balance.to_f - dr.amount.to_f)
    end
  end

  def down
  end
end
