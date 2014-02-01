class UnJobCostedItem < ActiveRecord::Base
  belongs_to :bill
  belongs_to :account
  attr_accessible :account_id, :amount, :bill_id, :description, :name, :reconciled

  before_save :refund_account, :charge_account
  after_destroy :refund_account

  default_scope { order(:created_at) }

  POSITIVES = ["Assets", "Expenses"]
  NEGATIVES = ["Liabilities", "Equity"]

  def paid?
    bill.paid?
  end

  def date
    bill.due_date
  end

  def method
    'Bill'
  end

  def payee
    bill.vendor.full_name
  end

  def reference
  end

  def memo
    bill.notes
  end

  def charge_account
    if account_id.present? && paid?
      account = Account.find(account_id)
      if account.kind_of? POSITIVES
        account.update_attribute(:balance, account.balance.to_f + self.amount.to_f)
      elsif account.kind_of? NEGATIVES
        account.update_attribute(:balance, account.balance.to_f - self.amount.to_f)
      end
    end
  end

  def refund_account
    if account_id_was.present? && paid?
      account_was = Account.find(account_id_was)
      if account_was.kind_of? POSITIVES
        account_was.update_attribute(:balance, account_was.balance.to_f - self.amount_was.to_f)
      elsif account.kind_of? NEGATIVES
        account_was.update_attribute(:balance, account_was.balance.to_f + self.amount_was.to_f)
      end
    end
  end
end
