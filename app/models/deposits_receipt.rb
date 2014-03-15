class DepositsReceipt < ActiveRecord::Base
  belongs_to :deposit
  belongs_to :receipt
  attr_accessible :amount, :receipt_id, :deposit_id

  before_save :refund_account_and_update_receipt, :charge_account_and_update_receipt
  after_destroy :refund_account_and_update_receipt

  private
  def charge_account_and_update_receipt
    remaining_amount = self.receipt.remaining_amount.presence ||self.receipt.amount
    self.amount = remaining_amount
    self.deposit.account.update_attribute(:balance, self.deposit.account.balance({recursive: false}).to_f + self.amount.to_f)
    self.receipt.update_column(:remaining_amount, remaining_amount.to_f - self.amount.to_f)
  end

  def refund_account_and_update_receipt
    self.deposit.account.update_attribute(:balance, self.deposit.account.balance({recursive: false}).to_f - self.amount_was.to_f)
    remaining_amount = self.receipt.billed? ? self.receipt.remaining_amount.to_f + self.amount_was.to_f : nil
    self.receipt.update_column(:remaining_amount, remaining_amount)
  end
end
