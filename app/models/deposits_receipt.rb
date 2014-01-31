class DepositsReceipt < ActiveRecord::Base
  belongs_to :deposit
  belongs_to :receipt
  attr_accessible :amount, :receipt_id, :deposit_id

  before_save :refund_account_and_update_receipt, :charge_account_and_update_receipt
  after_destroy :refund_account_and_update_receipt
  after_create :charge_account_for_uninvoiced_receipt
  before_destroy :refund_account_for_uninvoiced_receipt

  private
  def charge_account_and_update_receipt
    remaining_amount = self.receipt.remaining_amount.presence ||self.receipt.amount
    self.amount = remaining_amount
    self.deposit.account.update_attribute(:balance, self.deposit.account.balance.to_f + self.amount.to_f)
    self.receipt.update_column(:remaining_amount, remaining_amount.to_f - self.amount.to_f)
  end

  def refund_account_and_update_receipt
    self.deposit.account.update_attribute(:balance, self.deposit.account.balance.to_f - self.amount_was.to_f)
    remaining_amount = self.receipt.billed? ? self.receipt.remaining_amount.to_f + self.amount_was.to_f : nil
    self.receipt.update_column(:remaining_amount, remaining_amount)
  end

  def charge_account_for_uninvoiced_receipt
    return true unless receipt.uninvoiced
    receipt.receipts_items.each do |ri|
      ri.charge_account
    end
  end

  def refund_account_for_uninvoiced_receipt
    return true unless receipt.uninvoiced
    receipt.receipts_items.each do |ri|
      ri.refund_account
    end
  end
end
