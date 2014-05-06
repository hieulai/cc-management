class InvoicesItem < ActiveRecord::Base
  belongs_to :invoice
  belongs_to :item
  has_and_belongs_to_many :accounts
  counter_culture :invoice, :column_name => "cached_total_amount", :delta_column => 'amount'
  attr_accessible :amount, :invoice_id, :item_id

  scope :previous_created, lambda { |item_id, dt| where("item_id = ? and created_at < ?", item_id, dt) }
  scope :date_range, lambda { |from_date, to_date| joins(:invoice).where('invoices.invoice_date >= ? AND invoices.invoice_date <= ?', from_date, to_date) }
  scope :unrecociled, joins(:invoice).where('invoices.reconciled = false')
  scope :project, lambda { |project_id| joins(:invoice => :estimate).where('estimates.project_id = ?', project_id) }

  before_save :decrease_account, :increase_account
  after_save :update_invoices_accounts
  after_destroy :decrease_account, :refund_invoices_accounts

  def increase_account
    invoice.builder.accounts_receivable_account.update_column(:balance, invoice.builder.accounts_receivable_account.balance({recursive: false}).to_f + amount.to_f)
    if item.from_change_order?
      item.change_orders_category.revenue_account.update_column(:balance, item.change_orders_category.revenue_account.balance({recursive: false}).to_f + amount.to_f)
      self.accounts << item.change_orders_category.revenue_account
    elsif item.categories_templates.any?
      item.categories_templates.each do |ct|
        ct.revenue_account.update_column(:balance, ct.revenue_account.balance({recursive: false}).to_f + amount.to_f)
        self.accounts << ct.revenue_account
      end
    end
  end

  def decrease_account
    invoice.builder.accounts_receivable_account.update_column(:balance, invoice.builder.accounts_receivable_account.balance({recursive: false}).to_f - amount_was.to_f)
    if item.from_change_order?
      item.change_orders_category.revenue_account.update_column(:balance, item.change_orders_category.revenue_account.balance({recursive: false}).to_f - amount_was.to_f)
      self.accounts.delete item.change_orders_category.revenue_account
    elsif item.categories_templates.any?
      item.categories_templates.each do |ct|
        ct.revenue_account.update_column(:balance, ct.revenue_account.balance({recursive: false}).to_f - amount_was.to_f)
        self.accounts.delete ct.revenue_account
      end
    end
  end

  def update_invoices_accounts
    if item.from_change_order?
      revenue_ia = InvoicesAccount.where(invoice_id: invoice.id, account_id: item.change_orders_category.revenue_account.id).first_or_create
      revenue_ia.update_attributes({date: invoice.date, amount: revenue_ia.amount.to_f + amount.to_f})
    elsif item.categories_templates.any?
      item.categories_templates.each do |ct|
        revenue_ia = InvoicesAccount.where(invoice_id: invoice.id, account_id: ct.revenue_account.id).first_or_create
        revenue_ia.update_attributes({date: invoice.date, amount: revenue_ia.amount.to_f + amount.to_f})
      end
    end
  end

  def refund_invoices_accounts
    if item.from_change_order?
      revenue_ia = InvoicesAccount.where(invoice_id: invoice.id, account_id: item.change_orders_category.revenue_account.id).first_or_create
      revenue_ia.update_attributes({date: invoice.date, amount: revenue_ia.amount.to_f - amount_was.to_f})
      revenue_ia.destroy if item.change_orders_category.revenue_account.invoices_items.where(invoice_id: invoice_id).empty?
    elsif item.categories_templates.any?
      item.categories_templates.each do |ct|
        revenue_ia = InvoicesAccount.where(invoice_id: invoice.id, account_id: ct.revenue_account.id).first_or_create
        revenue_ia.update_attributes({date: invoice.date, amount: revenue_ia.amount.to_f - amount_was.to_f})
        revenue_ia.destroy if ct.revenue_account.invoices_items.where(invoice_id: invoice_id).empty?
      end
    end
  end
end
