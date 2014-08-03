class ChangeOrdersCategory < ActiveRecord::Base
  acts_as_paranoid
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
    has_paid_item? || has_invoiced_item?
  end

  def has_paid_item?
    items.select { |i| i.bills_items.any? || i.purchase_orders_items.any? }.any?
  end

  def has_invoiced_item?
    items.select { |i| i.billed? }.any?
  end

  def revenue_account
      category.builder.revenue_account.children.where(:name => self.category.name,
                                                      :builder_id => category.builder.revenue_account.builder_id).first_or_create
  end

  def cogs_account
        category.builder.cost_of_goods_sold_account.children.where(:name => category.name,
                                                                   :builder_id => category.builder.cost_of_goods_sold_account.builder_id).first_or_create
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
