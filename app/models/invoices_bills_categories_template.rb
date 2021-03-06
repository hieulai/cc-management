# == Schema Information
#
# Table name: invoices_bills_categories_templates
#
#  id                           :integer          not null, primary key
#  invoice_id                   :integer
#  bills_categories_template_id :integer
#  amount                       :decimal(10, 2)
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  deleted_at                   :time
#

class InvoicesBillsCategoriesTemplate < ActiveRecord::Base
  acts_as_paranoid
  belongs_to :invoice
  belongs_to :bills_categories_template
  has_and_belongs_to_many :accounts

  attr_accessible :amount, :invoice_id, :bills_categories_template_id

  scope :previous_created, lambda { |bills_categories_template_id, dt| where("bills_categories_template_id = ? and created_at < ?", bills_categories_template_id, dt) }
  scope :date_range, lambda { |from_date, to_date| joins(:invoice).where('invoices.invoice_date >= ? AND invoices.invoice_date <= ?', from_date, to_date) }
  scope :project, lambda { |project_id| joins(:invoice => :estimate).where('estimates.project_id = ?', project_id) }

  after_save :update_invoices_accounts
  after_destroy :refund_invoices_accounts

  def update_invoices_accounts
    revenue_ia = InvoicesAccount.where(invoice_id: invoice.id, account_id: bills_categories_template.categories_template.revenue_account.id).first_or_create
    revenue_ia.update_attributes({date: invoice.date, amount: revenue_ia.amount.to_f + amount.to_f})
  end

  def refund_invoices_accounts
    revenue_ia = InvoicesAccount.where(invoice_id: invoice.id, account_id: bills_categories_template.categories_template.revenue_account.id).first_or_create
    revenue_ia.update_attributes({date: invoice.date, amount: revenue_ia.amount.to_f - amount_was.to_f})
    revenue_ia.destroy if bills_categories_template.categories_template.revenue_account.invoices_bills_categories_templates.where(invoice_id: invoice_id).empty?
  end
end
