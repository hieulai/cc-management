class PaymentsBill < ActiveRecord::Base
  belongs_to :payment
  belongs_to :bill
  attr_accessible :amount, :bill_id, :payment_id

  before_save :refund_account_and_update_bill, :charge_account_and_update_bill
  after_destroy :refund_account_and_update_bill
  after_create :charge_account_for_un_job_costed_item
  before_destroy :refund_account_for_un_job_costed_item

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

  def charge_account_for_un_job_costed_item
    return true if bill.job_costed
    bill.un_job_costed_items.each do |ujci|
      ujci.charge_account
    end
  end

  def refund_account_for_un_job_costed_item
    return true if bill.job_costed
    bill.un_job_costed_items.each do |ujci|
      ujci.refund_account
    end
  end
end
