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
    change_account(true)
  end

  def decrease_account
    change_account(false)
  end

  private
  def change_account(positive)
    if item.change_order? || item.purchased?
      if item.change_order?
        category = item.change_orders_category.category
      elsif item.purchased?
        category = item.purchase_order.try(:categories_template).try(:category) || item.bill.try(:categories_template).try(:category)
      end
      r_account = category.builder.accounts.top.where(:name => Account::REVENUE).first
      r_ct_account = r_account.children.where(:name => category.name).first
      cogs_account = category.builder.accounts.top.where(:name => Account::COST_OF_GOODS_SOLD).first
      cogs_ct_account = cogs_account.children.where(:name => category.name).first
      r_ct_account.update_attribute(:balance, r_ct_account.balance.to_f + (positive ? amount.to_f : -1 * amount_was.to_f))
      cogs_ct_account.update_attribute(:balance, cogs_ct_account.balance.to_f + (positive ? amount.to_f : -1 * amount_was.to_f))
      if positive
        self.accounts << r_ct_account
        self.accounts << cogs_ct_account
      else
        self.accounts.delete r_ct_account
        self.accounts.delete cogs_ct_account
      end
    elsif item.categories_templates.any?
      item.categories_templates.each do |ct|
        ct.revenue_account.update_attribute(:balance, ct.revenue_account.balance.to_f + (positive ? amount.to_f : -1 * amount_was.to_f))
        ct.cogs_account.update_attribute(:balance, ct.cogs_account.balance.to_f + (positive ? amount.to_f : -1 * amount_was.to_f))
        if positive
          self.accounts << ct.revenue_account
          self.accounts << ct.cogs_account
        else
          self.accounts.delete ct.revenue_account
          self.accounts.delete ct.cogs_account
        end
      end
    end
  end
end
