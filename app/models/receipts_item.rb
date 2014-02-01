class ReceiptsItem < ActiveRecord::Base
  belongs_to :receipt
  belongs_to :account
  attr_accessible :name, :description, :amount, :reconciled, :receipt_id, :account_id

  before_save :refund_account, :charge_account
  after_destroy :refund_account

  POSITIVES = ["Liabilities", "Revenue", "Equity"]
  NEGATIVES = ["Assets"]

  def billed?
    receipt.billed?
  end

  def date
    receipt.received_at
  end

  def method
    'Receipt'
  end

  def payee
    receipt.payer_name
  end

  def reference
    receipt.reference
  end

  def memo
    receipt.notes
  end

  def charge_account
    if account_id.present? && billed?
      account = Account.find(self.account_id)
      if account.kind_of? POSITIVES
        account.update_attribute(:balance, account.balance.to_f + self.amount.to_f)
      elsif account.kind_of? NEGATIVES
        account.update_attribute(:balance, account.balance.to_f - self.amount.to_f)
      end
    end
  end

  def refund_account
    if account_id_was.present? && billed?
      account_was = Account.find(self.account_id_was)
      if account_was.kind_of? POSITIVES
        account_was.update_attribute(:balance, account_was.balance.to_f - self.amount_was.to_f)
      elsif account.kind_of? NEGATIVES
        account_was.update_attribute(:balance, account_was.balance.to_f + self.amount_was.to_f)
      end
    end
  end

end
