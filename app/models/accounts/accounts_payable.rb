module Accounts
  class AccountsPayable < Default

    def self_transactions
      r = super
      r << @account.builder.payments
      r << @account.builder.bills
      r
    end

    def date_balance(options={})
      b = super
      scoped_bills = options[:project_id].present? ? @account.bills.project(options[:project_id]) : @account.bills
      b_amount = scoped_bills.date_range(options[:from_date], options[:to_date]).map(&:cached_total_amount).compact.sum
      b + b_amount
    end

    def opening_balance
      0
    end
  end
end
