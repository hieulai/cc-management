require 'ostruct'
module Accounts
  class RetainedEarnings < Default

    def self_transactions
      t = super
      re = [OpenStruct.new(date: @account.opening_balance_updated_at,
                           id: @account.id,
                           type: "Retained Earnings",
                           reference: "",
                           payor: "Retained Earnings",
                           memo: "Retained Earnings Entry",
                           amount: @account.balance,
                           display_priority: 0)]
      re.define_singleton_method("account_amount") { self.amount }
      t + re
    end

    def balance(options = {})
      @account.builder.revenue_account.balance - @account.builder.expenses_account.balance
    end
  end
end
