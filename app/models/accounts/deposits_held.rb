module Accounts
  class DepositsHeld < Default

    def self_transactions
      r = super
      deposits = @account.builder.deposits
      deposits.each { |t| t.account_amount = -t.amount }
      r << deposits
      r << @account.builder.receipts
      r
    end

    def opening_balance
      0
    end
  end

end
