class DepositsReceipt < ActiveRecord::Base
  belongs_to :deposit
  belongs_to :receipt
  attr_accessible :amount, :receipt_id, :deposit_id
  counter_culture :deposit, :column_name => "cached_total_amount", :delta_column => 'amount'

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
