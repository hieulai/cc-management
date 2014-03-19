class MigrateInvoicesItemAmounts < ActiveRecord::Migration
  def up
    InvoicesItem.all.each do |ii|
      if ii.item.change_order?
        ii.item.change_orders_category.cogs_account.update_attribute(:balance, ii.item.change_orders_category.cogs_account.balance({recursive: false}).to_f - ii.amount.to_f)
        ii.accounts.delete ii.item.change_orders_category.cogs_account
      elsif ii.item.categories_templates.any?
        ii.item.categories_templates.each do |ct|
          ct.cogs_account.update_attribute(:balance, ct.cogs_account.balance({recursive: false}).to_f - ii.amount.to_f)
          ii.accounts.delete ct.cogs_account
        end
      end
      ii.invoice.builder.accounts_receivable_account.update_attribute(:balance, ii.invoice.builder.accounts_receivable_account.balance({recursive: false}).to_f + ii.amount.to_f)
    end

  end

  def down
  end
end
