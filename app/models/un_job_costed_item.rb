class UnJobCostedItem < ActiveRecord::Base
  belongs_to :bill
  belongs_to :account
  attr_accessible :account_id, :amount, :bill_id, :description, :name, :reconciled

  before_save :refund_account, :charge_account
  after_destroy :refund_account

  default_scope { order(:created_at) }
  scope :date_range, lambda { |from_date, to_date| joins(:bill).where("bills.due_date >= ? and bills.due_date <= ? ", from_date, to_date) }

  POSITIVES = ["Assets", "Expenses"]
  NEGATIVES = ["Liabilities", "Equity"]

  def paid?
    bill.paid?
  end

  def date
    bill.billed_date
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

  def display_priority
    1
  end

  def charge_account
    return true unless account_id
    account = Account.find(account_id)
    if account.kind_of? POSITIVES
      account.update_attribute(:balance, account.balance.to_f + self.amount.to_f)
    elsif account.kind_of? NEGATIVES
      account.update_attribute(:balance, account.balance.to_f - self.amount.to_f)
    end
  end

  def refund_account
    return true unless account_id_was
    account_was = Account.find(account_id_was)
    if account_was.kind_of? POSITIVES
      account_was.update_attribute(:balance, account_was.balance.to_f - self.amount_was.to_f)
    elsif account.kind_of? NEGATIVES
      account_was.update_attribute(:balance, account_was.balance.to_f + self.amount_was.to_f)
    end
  end
end
