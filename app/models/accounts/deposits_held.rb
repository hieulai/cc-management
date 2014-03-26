module Accounts
  class DepositsHeld < Default

    def self_transactions
      r = super
      r << @account.builder.deposits
      r << @account.builder.receipts
      r
    end

    def date_balance(options={})
      b = super
      deposits = @account.builder.deposits.date_range(options[:from_date], options[:to_date])
      receipts = @account.builder.receipts.date_range(options[:from_date], options[:to_date])

      trans = deposits + receipts
      trans.each { |t| t.related_account = @account }
      b + trans.map(&:account_amount).compact.sum
    end

    def bank_balance
      b = super
      deposits = @account.builder.deposits.unrecociled
      receipts = @account.builder.receipts.unrecociled
      trans = deposits + receipts
      trans.each { |t| t.related_account = @account }
      b + trans.map(&:account_amount).compact.sum
    end

    def opening_balance
      0
    end
  end

end
