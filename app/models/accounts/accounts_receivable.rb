module Accounts
  class AccountsReceivable < Default

    def self_transactions
      r = super
      r << @account.builder.invoices
      receipts =  @account.builder.receipts.invoiced
      receipts.each { |t| t.account_amount = -t.amount }
      r << receipts
      r
    end

    def opening_balance
      0
    end
  end
end
