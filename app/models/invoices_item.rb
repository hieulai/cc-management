# == Schema Information
#
# Table name: invoices_items
#
#  id         :integer          not null, primary key
#  invoice_id :integer
#  item_id    :integer
#  amount     :decimal(10, 2)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  deleted_at :time
#

class InvoicesItem < ActiveRecord::Base
  acts_as_paranoid
  belongs_to :invoice
  belongs_to :item
  has_and_belongs_to_many :accounts
  attr_accessible :amount, :invoice_id, :item_id

  scope :previous_created, lambda { |item_id, dt| where("item_id = ? and created_at < ?", item_id, dt) }
  scope :date_range, lambda { |from_date, to_date| joins(:invoice).where('invoices.invoice_date >= ? AND invoices.invoice_date <= ?', from_date, to_date) }
  scope :project, lambda { |project_id| joins(:invoice => :estimate).where('estimates.project_id = ?', project_id) }

  after_save :update_invoices_accounts
  after_destroy :refund_invoices_accounts

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
