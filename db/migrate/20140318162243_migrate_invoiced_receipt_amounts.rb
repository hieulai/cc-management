class MigrateInvoicedReceiptAmounts < ActiveRecord::Migration
  def up
    ReceiptsInvoice.all.each do |ri|
      ri.receipt.builder.accounts_receivable_account.update_attribute(:balance, ri.receipt.builder.accounts_receivable_account.balance({recursive: false}).to_f - ri.amount.to_f)
      ri.receipt.builder.deposits_held_account.update_attribute(:balance, ri.receipt.builder.deposits_held_account.balance({recursive: false}).to_f + ri.amount.to_f)
    end
  end

  def down
  end
end
