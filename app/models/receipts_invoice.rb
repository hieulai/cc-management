class ReceiptsInvoice < ActiveRecord::Base
  belongs_to :receipt
  belongs_to :invoice
  attr_accessible :amount, :receipt_id, :invoice_id

  before_save :refund_invoice, :update_invoice
  after_destroy :refund_invoice

  private
  def update_invoice
    receipt.builder.accounts_receivable_account.update_column(:balance, receipt.builder.accounts_receivable_account.balance({recursive: false}).to_f - self.amount.to_f)
    receipt.builder.deposits_held_account.update_column(:balance, receipt.builder.deposits_held_account.balance({recursive: false}).to_f + self.amount.to_f)
    # Avoid overbilled
    remaining_amount = self.invoice.remaining_amount.presence ||self.invoice.amount
    self.amount = remaining_amount if self.amount > remaining_amount
    self.invoice.update_column(:remaining_amount, remaining_amount - self.amount)
  end

  def refund_invoice
    receipt.builder.accounts_receivable_account.update_column(:balance, receipt.builder.accounts_receivable_account.balance({recursive: false}).to_f + self.amount_was.to_f)
    receipt.builder.deposits_held_account.update_column(:balance, receipt.builder.deposits_held_account.balance({recursive: false}).to_f - self.amount_was.to_f)
    remaining_amount = self.invoice.billed? ? self.invoice.remaining_amount + self.amount_was.to_f : nil
    self.invoice.update_column(:remaining_amount, remaining_amount)
  end
end
