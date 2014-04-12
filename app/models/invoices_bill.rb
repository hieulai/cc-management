class InvoicesBill < ActiveRecord::Base
  include Accountable
  belongs_to :invoice
  belongs_to :bill
  has_and_belongs_to_many :accounts
  attr_accessible :amount, :reconciled, :invoice_id, :bill_id

  scope :previous_created, lambda { |bill_id, dt| where("bill_id = ? and created_at < ?", bill_id, dt) }
  scope :date_range, lambda { |from_date, to_date| joins(:invoice).where('invoices.invoice_date >= ? AND invoices.invoice_date <= ?', from_date, to_date) }
  scope :unrecociled, joins(:invoice).where('invoices.reconciled = false')
  scope :project, lambda { |project_id| joins(:invoice => :estimate).where('estimates.project_id = ?', project_id) }

  before_save :decrease_account, :increase_account
  after_destroy :decrease_account
  NEGATIVES = []

  def increase_account
    invoice.builder.accounts_receivable_account.update_attribute(:balance, invoice.builder.accounts_receivable_account.balance({recursive: false}).to_f + amount.to_f)
    bill.categories_template.revenue_account.update_attribute(:balance, bill.categories_template.revenue_account.balance({recursive: false}).to_f + amount.to_f)
    self.accounts << bill.categories_template.revenue_account
  end

  def decrease_account
    invoice.builder.accounts_receivable_account.update_attribute(:balance, invoice.builder.accounts_receivable_account.balance({recursive: false}).to_f - amount_was.to_f)
    bill.categories_template.revenue_account.update_attribute(:balance, bill.categories_template.revenue_account.balance({recursive: false}).to_f - amount_was.to_f)
    self.accounts.delete bill.categories_template.revenue_account
  end
end
