class MigrateNonInvoicedReceiptAmounts < ActiveRecord::Migration
  def up
    ReceiptsItem.all.each do |ri|
      ri.receipt.builder.deposits_held_account.update_attribute(:balance, ri.receipt.builder.deposits_held_account.balance({recursive: false}).to_f + ri.amount.to_f)
    end
  end

  def down
  end
end
