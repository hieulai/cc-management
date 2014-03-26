class MigrateTransferAmounts < ActiveRecord::Migration
  def up
    Transfer.all.each do |t|
      if t.from_account && t.to_account
        t.from_account.update_attribute(:balance, t.from_account.balance({recursive: false}).to_f + t.amount.to_f)
        t.to_account.update_attribute(:balance, t.to_account.balance({recursive: false}).to_f - t.amount.to_f)

        t.from_account.update_attribute(:balance, t.from_account.balance({recursive: false}).to_f + t.absolute_amount(t.from_account, t.to_account, t.from_account))
        t.to_account.update_attribute(:balance, t.to_account.balance({recursive: false}).to_f + t.absolute_amount(t.from_account, t.to_account, t.to_account))
      end
    end
  end

  def down
  end
end
