require 'ostruct'
module Accounts
  class RetainedEarnings < Default

    def self_transactions
      t = super
      t << [OpenStruct.new(date: @account.opening_balance_updated_at,
                           id: @account.id,
                           type: "Retained Earnings",
                           reference: "",
                           payor: "Retained Earnings",
                           memo: "Retained Earnings Entry",
                           amount: @account.balance,
                           display_priority: 0)]
      t
    end

    def balance(options = {})
      @account.builder.revenue_account.balance - @account.builder.expenses_account.balance
    end

    def opening_balance
      0
    end
  end
end
