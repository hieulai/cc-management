class UnJobCostedItem < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :bill
  belongs_to :account
  attr_accessible :account_id, :amount, :bill_id, :description, :name, :reconciled

  before_save :refund_account, :unless => :deleted_at_changed?
  before_save :charge_account
  after_destroy :refund_account

  default_scope { order(:created_at) }
  scope :date_range, lambda { |from_date, to_date| joins(:bill).where("bills.billed_date >= ? and bills.billed_date <= ? ", from_date, to_date) }

  POSITIVES = [Account::ASSETS, Account::EXPENSES, Account::COST_OF_GOODS_SOLD]
  NEGATIVES = [Account::LIABILITIES, Account::EQUITY, Account::REVENUE]

  def paid?
    bill.paid?
  end

  def date
    bill.billed_date
  end

  def display_priority
    1
  end

  def charge_account
    return true unless account_id
    bill.builder.accounts_payable_account.update_attribute(:balance, bill.builder.accounts_payable_account.balance({recursive: false}).to_f + self.amount.to_f)
    account = Account.find(account_id)
    if account.kind_of? POSITIVES
      account.update_attribute(:balance, account.balance({recursive: false}).to_f + self.amount.to_f)
    elsif account.kind_of? NEGATIVES
      account.update_attribute(:balance, account.balance({recursive: false}).to_f - self.amount.to_f)
    end
  end

  def refund_account
    return true unless account_id_was
    bill.builder.accounts_payable_account.update_attribute(:balance, bill.builder.accounts_payable_account.balance({recursive: false}).to_f - self.amount_was.to_f)
    account_was = Account.find(account_id_was)
    if account_was.kind_of? POSITIVES
      account_was.update_attribute(:balance, account_was.balance({recursive: false}).to_f - self.amount_was.to_f)
    elsif account.kind_of? NEGATIVES
      account_was.update_attribute(:balance, account_was.balance({recursive: false}).to_f + self.amount_was.to_f)
    end
  end
end
