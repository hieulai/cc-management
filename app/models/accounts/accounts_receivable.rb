module Accounts
  class AccountsReceivable < Default

    def self_transactions
      r = super
      r << @account.builder.invoices
      r << @account.builder.receipts.invoiced
      r
    end

    def opening_balance
      0
    end
  end
end
