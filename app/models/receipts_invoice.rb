# == Schema Information
#
# Table name: receipts_invoices
#
#  id         :integer          not null, primary key
#  receipt_id :integer
#  invoice_id :integer
#  amount     :decimal(10, 2)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  deleted_at :time
#

class ReceiptsInvoice < ActiveRecord::Base
  acts_as_paranoid
  belongs_to :receipt
  belongs_to :invoice
  attr_accessible :amount, :receipt_id, :invoice_id

  scope :project, lambda { |project_id| joins(:invoice => :estimate).where('estimates.project_id = ?', project_id) }
  before_save :refund_invoice, :update_invoice
  after_destroy :refund_invoice

  private
  def update_invoice
    remaining_amount = self.invoice.remaining_amount.presence ||self.invoice.amount
    self.amount = remaining_amount if self.amount > remaining_amount
    self.invoice.update_column(:remaining_amount, remaining_amount - self.amount)
  end

  def refund_invoice
    self.invoice.update_column(:remaining_amount, self.invoice.billed? ? self.invoice.remaining_amount + self.amount_was.to_f : nil)
  end
end
