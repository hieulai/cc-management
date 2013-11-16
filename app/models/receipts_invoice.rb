class ReceiptsInvoice < ActiveRecord::Base
  belongs_to :receipt
  belongs_to :invoice
  attr_accessible :amount, :receipt_id, :invoice_id

  before_save :refund_invoice, :update_invoice

  after_destroy :refund_invoice

  private
  def update_invoice
    # Avoid overbilled
    remaining_amount = self.invoice.remaining_amount.presence ||self.invoice.amount
    self.amount = remaining_amount if self.amount > remaining_amount
    self.invoice.update_column(:remaining_amount, remaining_amount - self.amount)
  end

  def refund_invoice
    remaining_amount = self.invoice.billed? ? self.invoice.remaining_amount + self.amount_was.to_f : nil
    self.invoice.update_column(:remaining_amount, remaining_amount)
  end
end
