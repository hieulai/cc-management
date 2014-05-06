class ReceiptsItem < ActiveRecord::Base
  belongs_to :receipt
  belongs_to :account
  attr_accessible :name, :description, :amount, :reconciled, :receipt_id, :account_id
  counter_culture :receipt, :column_name => "cached_total_amount", :delta_column => 'amount'
  before_save :refund_account, :charge_account
  after_save :update_transactions
  after_destroy :refund_account, :destroy_transactions

  scope :date_range, lambda { |from_date, to_date| joins(:receipt).where("receipts.received_at >= ? and receipts.received_at <= ? ", from_date, to_date) }
  scope :unrecociled, where(:reconciled => false)

  POSITIVES = [Account::LIABILITIES, Account::REVENUE, Account::EQUITY]
  NEGATIVES = [Account::ASSETS, Account::COST_OF_GOODS_SOLD, Account::EXPENSES]

  def receipted?
    receipt.receipted?
  end

  def date
    receipt.received_at
  end

  def account_amount(a, r_account)
    (a || 0) * (r_account.kind_of?(NEGATIVES) ? -1 : 1)
  end

  def charge_account
    return true unless account_id
    receipt.builder.deposits_held_account.update_column(:balance, receipt.builder.deposits_held_account.balance({recursive: false}).to_f + self.amount.to_f)
    account = Account.find(account_id)
    account.update_column(:balance, account.balance({recursive: false}).to_f + account_amount(amount, account))
  end

  def refund_account
    return true unless account_id_was
    receipt.builder.deposits_held_account.update_column(:balance, receipt.builder.deposits_held_account.balance({recursive: false}).to_f - self.amount_was.to_f)
    account_was = Account.find(account_id_was)
    account_was.update_column(:balance, account_was.balance({recursive: false}).to_f - account_amount(amount_was, account_was))
  end

  def update_transactions
    if account_id_was
      rat_was = receipt.accounting_transactions.where(account_id: account_id_was).first
      if rat_was
        account_was = Account.find(account_id_was)
        rat_was.update_attributes({date: date, amount: rat_was.amount.to_f - account_amount(amount_was, account_was)})
        rat_was.destroy if receipt.receipts_items.where(account_id: account_id_was).empty?
      end
    end
    rat = receipt.accounting_transactions.where(account_id: account_id).first_or_create
    rat.update_attributes({date: date, amount: rat.amount.to_f + account_amount(amount, account)})
  end

  def destroy_transactions
    receipt.accounting_transactions.where(account_id: account_id_was).destroy_all if receipt.receipts_items.where(account_id: account_id_was).empty?
  end
end
