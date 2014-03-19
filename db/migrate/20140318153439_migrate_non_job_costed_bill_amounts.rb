class MigrateNonJobCostedBillAmounts < ActiveRecord::Migration
  def up
    UnJobCostedItem.all.each do |ujci|
      ujci.bill.builder.accounts_payable_account.update_attribute(:balance, ujci.bill.builder.accounts_payable_account.balance({recursive: false}).to_f + ujci.amount.to_f)
    end
  end

  def down
  end
end
