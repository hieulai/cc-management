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
      scoped_bills = options[:project_id].present? ? @account.builder.bills.project(options[:project_id]) : @account.builder.bills
      bills = scoped_bills.date_range(options[:from_date], options[:to_date])
      payments = @account.builder.payments.date_range(options[:from_date], options[:to_date])

      trans = bills + payments
      trans.each { |t| t.related_account = @account }
      b + trans.map(&:account_amount).compact.sum
    end

    def bank_balance
      b = super
      payments = @account.builder.payments.unrecociled
      bills = @account.builder.bills.unrecociled
      trans = bills + payments
      trans.each { |t| t.related_account = @account }
      b + trans.map(&:account_amount).compact.sum
    end

    def opening_balance
      0
    end
  end
end
