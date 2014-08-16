# == Schema Information
#
# Table name: payments_bills
#
#  id         :integer          not null, primary key
#  payment_id :integer
#  bill_id    :integer
#  amount     :decimal(10, 2)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  deleted_at :time
#

class PaymentsBill < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :payment
  belongs_to :bill, touch: true
  attr_accessible :amount, :bill_id, :payment_id

  scope :project, lambda { |project_id| joins(:bill).where('bills.project_id = ?', project_id) }
  before_save :increase_bill_remaining_amount, :decrease_bill_remaining_amount
  after_destroy :increase_bill_remaining_amount

  private
  def decrease_bill_remaining_amount
    remaining_amount = self.bill.remaining_amount.presence||self.bill.source(:total_amount)
    self.amount = remaining_amount if self.amount > remaining_amount
    self.bill.update_column(:remaining_amount, remaining_amount - self.amount)
  end

  def increase_bill_remaining_amount
    self.bill.update_column(:remaining_amount, self.bill.paid? ? self.bill.remaining_amount.to_f + self.amount_was.to_f : nil)
  end
end
