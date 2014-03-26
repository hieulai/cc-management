module Accounts
  class AccountsReceivable < Default

    def self_transactions
      r = super
      r << @account.builder.invoices
      r << @account.builder.receipts.invoiced
      r
    end

    def date_balance(options={})
      b = super
      scoped_invoices = options[:project_id].present? ? @account.builder.invoices.project(options[:project_id]) : @account.builder.invoices
      invoices = scoped_invoices.date_range(options[:from_date], options[:to_date])
      receipts = @account.builder.receipts.invoiced.date_range(options[:from_date], options[:to_date])

      trans = invoices + receipts
      trans.each { |t| t.related_account = @account }
      b + trans.map(&:account_amount).compact.sum
    end

    def bank_balance
      b = super
      invoices = @account.builder.invoices.unrecociled
      receipts = @account.builder.receipts.invoiced.unrecociled
      trans = invoices + receipts
      trans.each { |t| t.related_account = @account }
      b + trans.map(&:account_amount).compact.sum
    end

    def opening_balance
      0
    end
  end
end
