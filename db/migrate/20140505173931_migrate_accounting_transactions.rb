class MigrateAccountingTransactions < ActiveRecord::Migration
  def up
    Bill.all.each do |e|
      unless e.save
        puts "Saving Bill failed: #{e.id}, #{e.errors.full_messages}"
      end
      e.accounting_transactions.each do |at|
         at.update_column(:reconciled, e.reconciled)
      end
    end
    Deposit.all.each do |e|
      unless e.save
        puts "Saving Deposit failed: #{e.id}, #{e.errors.full_messages}"
      end
      e.accounting_transactions.each do |at|
        at.update_column(:reconciled, e.reconciled)
      end
    end
    Invoice.all.each do |e|
      unless e.save
        puts "Saving Invoice failed: #{e.id}, #{e.errors.full_messages}"
      end
      e.accounting_transactions.each do |at|
        at.update_column(:reconciled, e.reconciled)
      end
    end
    InvoicesBill.all.each do |e|
      unless e.save
        puts "Saving InvoicesBill failed: #{e.id}, #{e.errors.full_messages}"
      end
      revenue_ia = InvoicesAccount.where(invoice_id: e.invoice.id, account_id: e.bill.categories_template.revenue_account.id).first
      revenue_ia.accounting_transactions.each do |at|
        at.update_column(:reconciled, e.invoice.reconciled)
      end
    end
    InvoicesItem.all.each do |e|
      unless e.save
        puts "Saving InvoicesItem failed: #{e.id}, #{e.errors.full_messages}"
      end
      if e.item.from_change_order?
        revenue_ia = InvoicesAccount.where(invoice_id: e.invoice.id, account_id: e.item.change_orders_category.revenue_account.id).first
        revenue_ia.accounting_transactions.each do |at|
          at.update_column(:reconciled, e.invoice.reconciled)
        end
      elsif e.item.categories_templates.any?
        e.item.categories_templates.each do |ct|
          revenue_ia = InvoicesAccount.where(invoice_id: e.invoice.id, account_id: ct.revenue_account.id).first
          revenue_ia.accounting_transactions.each do |at|
            at.update_column(:reconciled, e.invoice.reconciled)
          end
        end
      end
    end
    Payment.all.each do |e|
      unless e.save
        puts "Saving Payment failed: #{e.id}, #{e.errors.full_messages}"
      end
      e.accounting_transactions.each do |at|
        at.update_column(:reconciled, e.reconciled)
      end
    end
    Receipt.all.each do |e|
      unless e.save
        puts "Saving Receipt failed: #{e.id}, #{e.errors.full_messages}"
      end
      e.accounting_transactions.each do |at|
        at.update_column(:reconciled, e.reconciled)
      end
    end
    ReceiptsItem.all.each do |e|
      unless e.save
        puts "Saving ReceiptsItem failed: #{e.id}, #{e.errors.full_messages}"
      end
      rat = e.receipt.accounting_transactions.where(account_id: e.account_id).first
      rat.update_column(:reconciled, e.reconciled)
    end
    UnJobCostedItem.all.each do |e|
      unless e.save
        puts "Saving UnJobCostedItem failed: #{e.id}, #{e.errors.full_messages}"
      end
      bat = e.bill.accounting_transactions.where(account_id: e.account_id).first
      bat.update_column(:reconciled, e.reconciled)
    end
    Transfer.all.each do |e|
      unless e.save
        puts "Saving Transfer failed: #{e.id}, #{e.errors.full_messages}"
      end
      e.accounting_transactions.each do |at|
        at.update_column(:reconciled, e.reconciled)
      end
    end
    Account.all.each do |a|
      next unless a.kind_of? [Account::BANK_ACCOUNTS]
      unless a.save
        puts "Saving Account failed: #{a.id}, #{a.errors.full_messages}"
      end
    end
  end
end
