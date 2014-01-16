class PaymentsBill < ActiveRecord::Base
  belongs_to :payment
  belongs_to :bill
  attr_accessible :amount, :bill_id, :payment_id

  before_save :refund_account_and_update_bill, :charge_account_and_update_bill

  after_destroy :refund_account_and_update_bill

  private
  def charge_account_and_update_bill
    self.payment.account.update_attribute(:balance, self.payment.account.balance.to_f - self.amount)
    # Avoid overpaid
    remaining_amount = self.bill.remaining_amount.presence||self.bill.source(:total_amount)
    self.amount = remaining_amount if self.amount > remaining_amount
    self.bill.update_column(:remaining_amount, remaining_amount - self.amount)
  end

  def refund_account_and_update_bill
    self.payment.account.update_attribute(:balance, self.payment.account.balance.to_f + self.amount_was.to_f)
    remaining_amount = self.bill.paid? ? self.bill.remaining_amount + self.amount_was.to_f : nil
    self.bill.update_column(:remaining_amount, remaining_amount)
  end
end
