class CategoriesTemplate < ActiveRecord::Base
  acts_as_paranoid
  before_destroy :check_destroyable, :destroy_items
  after_destroy :destroy_accounts, :if => Proc.new{|ct| ct.template.estimate.present? }

  attr_accessible :category_id, :template_id, :items_attributes, :purchased

  belongs_to :template
  belongs_to :category
  has_many :purchase_orders, :dependent => :destroy
  has_many :bills, :dependent => :destroy
  has_and_belongs_to_many :items
  has_and_belongs_to_many :accounts
  accepts_nested_attributes_for :items, allow_destroy: true

  after_create :create_accounts, :if => Proc.new{|ct| ct.template.estimate.present? }

  validates_presence_of :template, :category

  def category_name
    self.category.name
  end

  def pos
    purchase_orders.where(:chosen => true)
  end

  def merged_purchasable_items
    po_ids = purchase_orders.pluck(:id)
    bill_ids = bills.pluck(:id)
    r = Array.new
    Item.where('purchase_order_id in (?)  or bill_id in (?)', po_ids, bill_ids).group_by(&:name).each do |name, list|
      estimated_cost = list.map(&:amount).compact.sum
      actual_cost = list.map(&:actual_cost).compact.sum
      margin = list.map(&:margin).compact.sum
      r << Item.new(:name => name, :description => list.first.description, :estimated_cost => estimated_cost, :margin => margin, :actual_cost => actual_cost, :purchase_order_id => list.first.purchase_order_id, :bill_id => list.first.bill_id)
    end
    return r
  end

  def co_items
    template.try(:estimate).try(:project).try(:co_items, category) || Array.new
  end

  def undestroyable?
    items.select { |i| i.billed? }.any? || co_items.select { |i| i.billed? }.any?
  end

  def estimated_amount
    p = self.template.estimate.cost_plus_bid? ? :amount : :price
    items.map(&p).compact.sum
  end

  def revenue_account
    return nil unless self.template.estimate
    builder = self.template.estimate.builder
    r_account = builder.revenue_account
    ct_account = r_account.children.where(:name => self.category.name).first
    unless ct_account
      ct_account = r_account.children.create(:name => self.category.name, :builder_id => r_account.builder_id)
    end
    unless self.accounts.include? ct_account
      self.accounts << ct_account
    end

    ct_account
  end

  def cogs_account
    return nil unless self.template.estimate
    builder = self.template.estimate.builder
    cogs_account = builder.cost_of_goods_sold_account
    ct_account = cogs_account.children.where(:name => self.category.name).first
    unless ct_account
      ct_account = cogs_account.children.create(:name => self.category.name, :builder_id => cogs_account.builder_id)
    end
    unless self.accounts.include? ct_account
      self.accounts << ct_account
    end
    ct_account
  end

  def update_indexes
    Sunspot.delay.index bills
    Sunspot.delay.index purchase_orders
  end

  private
  def check_destroyable
    if self.undestroyable?
      errors[:base] << "Category Template #{id} cannot be deleted once containing items which are added to an invoice"
      false
    end
  end

  def destroy_items
    items.destroy_all
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
