class ReceiptsItem < ActiveRecord::Base
  belongs_to :receipt
  belongs_to :account
  attr_accessible :name, :description, :amount, :reconciled, :receipt_id, :account_id

  before_save :refund_account, :charge_account
  after_destroy :refund_account

  scope :date_range, lambda { |from_date, to_date| joins(:receipt).where("receipts.received_at >= ? and receipts.received_at <= ? ", from_date, to_date) }

  POSITIVES = [Account::LIABILITIES, Account::REVENUE, Account::EQUITY]
  NEGATIVES = [Account::ASSETS]

  def billed?
    receipt.billed?
  end

  def date
    receipt.received_at
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
