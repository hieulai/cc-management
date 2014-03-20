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
      p_amount = @account.payments.date_range(options[:from_date], options[:to_date]).map(&:amount).compact.sum
      d_amount = @account.deposits.date_range(options[:from_date], options[:to_date]).map(&:amount).compact.sum
      st_amount = @account.sent_transfers.date_range(options[:from_date], options[:to_date]).map(&:amount).compact.sum
      rt_amount = @account.received_transfers.date_range(options[:from_date], options[:to_date]).map(&:amount).compact.sum
      if @account.kind_of? ReceiptsItem::POSITIVES
        ri_amount = @account.receipts_items.date_range(options[:from_date], options[:to_date]).map(&:amount).compact.sum
      elsif @account.kind_of? ReceiptsItem::NEGATIVES
        ri_amount -= @account.receipts_items.date_range(options[:from_date], options[:to_date]).map(&:amount).compact.sum
      end
      if @account.kind_of? UnJobCostedItem::POSITIVES
        ujci_amount += @account.un_job_costed_items.date_range(options[:from_date], options[:to_date]).map(&:amount).compact.sum
      elsif @account.kind_of? UnJobCostedItem::NEGATIVES
        ujci_amount -= @account.un_job_costed_items.date_range(options[:from_date], options[:to_date]).map(&:amount).compact.sum
      end
      scoped_invoices_items = options[:project_id].present? ? invoices_items.project(options[:project_id]) : invoices_items
      ii_amount = scoped_invoices_items.date_range(options[:from_date], options[:to_date]).map(&:amount).compact.sum

      -p_amount + d_amount - st_amount + rt_amount + ri_amount + ujci_amount + ii_amount
    end

    def bank_balance
      bb = @account.balance({recursive: false}).to_f +
          @account.payments.where(:reconciled => false).map(&:amount).compact.sum -
          @account.deposits.where(:reconciled => false).map(&:amount).compact.sum -
          @account.received_transfers.where(:reconciled => false).map(&:amount).compact.sum +
          @account.sent_transfers.where(:reconciled => false).map(&:amount).compact.sum -
          @account.bills.where(:reconciled => false).map(&:cached_total_amount).compact.sum -
          @account.invoices_items.unrecociled.map(&:amount).compact.sum
      if @account.receipts_items.any?
        if @account.kind_of? ReceiptsItem::POSITIVES
          bb-= @account.receipts_items.select {|ri| !ri.reconciled}.map(&:amount).compact.sum
        elsif @account.kind_of? ReceiptsItem::NEGATIVES
          bb+= @account.receipts_items.select {|ri| !ri.reconciled}.map(&:amount).compact.sum
        end
      end

      if @account.un_job_costed_items.any?
        if @account.kind_of? UnJobCostedItem::POSITIVES
          bb-= @account.un_job_costed_items.select {|ri| !ri.reconciled}.map(&:amount).compact.sum
        elsif @account.kind_of? UnJobCostedItem::NEGATIVES
          bb+= @account.un_job_costed_items.select {|ri| !ri.reconciled}.map(&:amount).compact.sum
        end
      end
      bb.round(2)
    end

    def book_balance
      @account.balance.to_f
    end

    def outstanding_checks_balance
      @account.payments.where(:reconciled => false).map(&:amount).compact.sum
    end

    def opening_balance
      ob = @account.balance({recursive: false}).to_f +
          @account.payments.map(&:amount).compact.sum -
          @account.deposits.map(&:amount).compact.sum -
          @account.received_transfers.map(&:amount).compact.sum +
          @account.sent_transfers.map(&:amount).compact.sum -
          @account.invoices_items.map(&:amount).compact.sum
      if @account.receipts_items.any?
        if @account.kind_of? ReceiptsItem::POSITIVES
          ob-= @account.receipts_items.map(&:amount).compact.sum
        elsif @account.kind_of? ReceiptsItem::NEGATIVES
          ob+= @account.receipts_items.map(&:amount).compact.sum
        end
      end

      if @account.un_job_costed_items.any?
        if @account.kind_of? UnJobCostedItem::POSITIVES
          ob-= @account.un_job_costed_items.map(&:amount).compact.sum
        elsif @account.kind_of? UnJobCostedItem::NEGATIVES
          ob+= @account.un_job_costed_items.map(&:amount).compact.sum
        end
      end
      ob.round(2)
    end
  end
end
