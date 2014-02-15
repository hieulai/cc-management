class InvoicesItem < ActiveRecord::Base
  belongs_to :invoice
  belongs_to :item
  has_and_belongs_to_many :accounts
  attr_accessible :amount, :reconciled, :invoice_id, :item_id

  scope :previous_created_by_item, lambda { |item_id, dt| where("item_id = ? and created_at < ?", item_id, dt) }
  scope :date_range, lambda { |from_date, to_date| joins(:invoice).where('invoices.invoice_date >= ? AND invoices.invoice_date <= ?', from_date, to_date) }

  before_save :decrease_account, :increase_account
  after_destroy :decrease_account

  def increase_account
    item.categories_templates.each do |ct|
      ct.revenue_account.update_attribute(:balance, ct.revenue_account.balance.to_f + amount.to_f)
      ct.cogs_account.update_attribute(:balance, ct.cogs_account.balance.to_f + amount.to_f)
      self.accounts << ct.revenue_account
      self.accounts << ct.cogs_account
    end
  end

  def decrease_account
    item.categories_templates.each do |ct|
      ct.revenue_account.update_attribute(:balance, ct.revenue_account.balance.to_f - amount_was.to_f)
      ct.cogs_account.update_attribute(:balance, ct.cogs_account.balance.to_f - amount_was.to_f)
      self.accounts.delete ct.revenue_account
      self.accounts.delete ct.cogs_account
    end
  end

end
