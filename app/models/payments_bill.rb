class PaymentsBill < ActiveRecord::Base
  belongs_to :payment
  belongs_to :bill
  attr_accessible :paid_amount, :bill_id, :payment_id

  before_create :charge_account_and_update_bill

  after_destroy :refund_account_and_update_bill

  private
  def charge_account_and_update_bill
    self.payment.account.update_attribute(:balance, self.payment.account.balance - self.paid_amount)
    # Avoid overpaid
    remaining_amount = self.bill.remaining_amount.presence||self.bill.total_amount
    self.paid_amount = remaining_amount if self.paid_amount > remaining_amount
    self.bill.update_column(:remaining_amount, remaining_amount - self.paid_amount)
  end

  def refund_account_and_update_bill
    self.payment.account.update_attribute(:balance, self.payment.account.balance + self.paid_amount_was)
    remaining_amount = self.bill.paid? ? self.bill.remaining_amount + self.paid_amount_was : nil
    self.bill.update_column(:remaining_amount, remaining_amount)
  end
end
