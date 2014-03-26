require 'ostruct'
module Accounts
  class Default
    attr_accessor :account

    def initialize(account)
      @account = account
    end

    def transactions
      t = []
      st = self.self_transactions.flatten
      st.each { |t| t.related_account = @account }
      t << st
      t << @account.children.map { |a| a.transactions }
      t.flatten.sort_by { |x| [x.date.try(:to_date) || Date.new(0), x.display_priority] }.reverse!
    end

    def self_transactions
      t = []
      if @account.kind_of? [Account::BANK_ACCOUNTS]
        ob = OpenStruct.new(date: @account.opening_balance_updated_at,
                            id: @account.id,
                            type: "Opening Balance",
                            reference: "",
                            payor: "Opening Balance",
                            memo: @account.name + " Opening Balance Entry",
                            amount: @account.opening_balance,
                            display_priority: 0)
        ob.define_singleton_method("account_amount") { self.amount }
        t << ob
      end
      t << @account.payments + @account.deposits + @account.sent_transfers + @account.received_transfers + @account.receipts_items + @account.un_job_costed_items + @account.invoices + @account.bills
    end

    def balance(options ={})
      options ||= {}
      options[:recursive] = true if options[:recursive].nil?
      if options[:from_date] && options[:to_date]
        b = self.date_balance(options)
      else
        b = self.self_balance
      end
      b+= (@account.children.map { |a| a.balance(options) }).compact.sum if options[:recursive]
      b
    end

    def self_balance
      @account.read_attribute(:balance).to_f
    end

    def date_balance(options = {})
      payments = @account.payments.date_range(options[:from_date], options[:to_date])
      deposits = @account.deposits.date_range(options[:from_date], options[:to_date])
      sent_transfers = @account.sent_transfers.date_range(options[:from_date], options[:to_date])
      received_transfers = @account.received_transfers.date_range(options[:from_date], options[:to_date])
      receipt_items = @account.receipts_items.date_range(options[:from_date], options[:to_date])
      un_job_costed_items = @account.un_job_costed_items.date_range(options[:from_date], options[:to_date])
      scoped_bills = options[:project_id].present? ? @account.bills.project(options[:project_id]) : @account.bills
      bills = scoped_bills.date_range(options[:from_date], options[:to_date])
      scoped_invoices_items = options[:project_id].present? ? @account.invoices_items.project(options[:project_id]) : @account.invoices_items
      invoices_items = scoped_invoices_items.date_range(options[:from_date], options[:to_date])

      trans = payments + deposits + sent_transfers + received_transfers + receipt_items + un_job_costed_items + invoices_items + bills
      trans.each { |t| t.related_account = @account }
      trans.map(&:account_amount).compact.sum
    end

    def bank_balance
      bb = @account.balance({recursive: false}).to_f
      trans = @account.payments.unrecociled + @account.deposits.unrecociled + @account.received_transfers.unrecociled +
          @account.sent_transfers.unrecociled + @account.receipts_items.unrecociled + @account.un_job_costed_items.unrecociled +
          @account.invoices_items.unrecociled + @account.bills.unrecociled
      trans.each { |t| t.related_account = @account }
      bb -= trans.map(&:account_amount).compact.sum
      bb.round(2)
    end

    def book_balance
      @account.balance.to_f
    end

    def outstanding_checks_balance
      @account.payments.unrecociled.map(&:amount).compact.sum
    end

    def opening_balance
      ob = @account.balance({recursive: false}).to_f
      tr = @account.payments + @account.deposits + @account.received_transfers + @account.sent_transfers +
          @account.receipts_items + @account.un_job_costed_items + @account.invoices_items + @account.bills.unrecociled
      tr.each { |t| t.related_account = @account }
      ob -= tr.map(&:account_amount).compact.sum
      ob.round(2)
    end
  end
end
