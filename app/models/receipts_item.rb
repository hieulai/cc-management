class ReceiptsItem < ActiveRecord::Base
  include Accountable

  belongs_to :receipt
  belongs_to :account
  attr_accessible :name, :description, :amount, :reconciled, :receipt_id, :account_id

  before_save :refund_account, :charge_account
  after_destroy :refund_account

  scope :date_range, lambda { |from_date, to_date| joins(:receipt).where("receipts.received_at >= ? and receipts.received_at <= ? ", from_date, to_date) }
  scope :unrecociled, where(:reconciled => false)

  POSITIVES = [Account::LIABILITIES, Account::REVENUE, Account::EQUITY]
  NEGATIVES = [Account::ASSETS, Account::COST_OF_GOODS_SOLD, Account::EXPENSES]

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
    receipt.builder.deposits_held_account.update_column(:balance, receipt.builder.deposits_held_account.balance({recursive: false}).to_f + self.amount.to_f)
    account = Account.find(account_id)
    self.related_account = account
    account.update_column(:balance, account.balance({recursive: false}).to_f + account_amount)
  end

  def refund_account
    return true unless account_id_was
    receipt.builder.deposits_held_account.update_column(:balance, receipt.builder.deposits_held_account.balance({recursive: false}).to_f - self.amount_was.to_f)
    account_was = Account.find(account_id_was)
    self.related_account = account_was
    account_was.update_column(:balance, account_was.balance({recursive: false}).to_f - account_amount)
  end
end
