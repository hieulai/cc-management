module Accounts
  class DepositsHeld < Default

    def self_transactions
      r = super
      r << @account.builder.deposits
      r << @account.builder.receipts
      r
    end
  end

end
