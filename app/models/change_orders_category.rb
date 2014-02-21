class ChangeOrdersCategory < ActiveRecord::Base
  before_destroy :check_destroyable
  after_destroy :destroy_accounts

  belongs_to :change_order
  belongs_to :category
  has_many :items, :dependent => :destroy
  has_and_belongs_to_many :accounts
  attr_accessible :category_id, :change_order_id, :items_attributes
  accepts_nested_attributes_for :items, allow_destroy: true

  after_create :create_accounts

  def amount
    items.map(&:price).compact.sum
  end

  def undestroyable?
    items.select { |i| i.billed? }.any?
  end

  def has_paid_item?
    items.select { |i| i.bills_items.any? || i.purchase_orders_items.any? }.any?
  end

  def revenue_account
    r_account = self.category.builder.accounts.top.where(:name => Account::REVENUE).first
    r_account.children.where(:name => self.category.name, :builder_id => r_account.builder_id).first_or_create
  end

  def cogs_account
    cogs_account = category.builder.accounts.top.where(:name => Account::COST_OF_GOODS_SOLD).first
    cogs_account.children.where(:name => category.name, :builder_id => cogs_account.builder_id).first_or_create
  end

  private
  def check_destroyable
    if self.undestroyable?
      errors[:invoice] << "Change Order Category #{id} cannot be deleted once containing items which are added to an invoice"
      false
    end
  end

  def create_accounts
    revenue_account
    cogs_account
  end

  def destroy_accounts
    revenue_account.destroy if revenue_account.has_no_category?
    cogs_account.destroy if cogs_account.has_no_category?
  end
end
