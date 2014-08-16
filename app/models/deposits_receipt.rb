# == Schema Information
#
# Table name: deposits_receipts
#
#  id         :integer          not null, primary key
#  deposit_id :integer
#  receipt_id :integer
#  amount     :decimal(10, 2)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  deleted_at :time
#

class DepositsReceipt < ActiveRecord::Base
  acts_as_paranoid
  belongs_to :deposit
  belongs_to :receipt
  attr_accessible :amount, :receipt_id, :deposit_id

  before_save :increase_receipt_remaining_amount, :decrease_receipt_remaining_amount
  after_destroy :increase_receipt_remaining_amount

  private
  def decrease_receipt_remaining_amount
    remaining_amount = self.receipt.remaining_amount.presence ||self.receipt.amount
    self.amount = remaining_amount
    self.receipt.update_column(:remaining_amount, remaining_amount.to_f - self.amount.to_f)
  end

  def increase_receipt_remaining_amount
    self.receipt.update_column(:remaining_amount, self.receipt.billed? ? self.receipt.remaining_amount.to_f + self.amount_was.to_f : nil)
  end
end
