class CategoriesTemplate < ActiveRecord::Base
  acts_as_paranoid
  before_destroy :check_destroyable

  belongs_to :template
  belongs_to :category
  has_many :bills_categories_templates, :dependent => :destroy
  has_many :purchase_orders_categories_templates, :dependent => :destroy
  has_many :bills, :through => :bills_categories_templates
  has_many :purchase_orders, :through => :purchase_orders_categories_templates

  has_and_belongs_to_many :items
  has_and_belongs_to_many :accounts

  attr_accessible :category_id, :template_id, :items_attributes, :purchased
  accepts_nested_attributes_for :items, allow_destroy: true

  after_create :create_accounts
  after_destroy :destroy_items, :destroy_accounts, :destroy_category

  validates_presence_of :template, :category

  def category_name
    self.category.name
  end

  def pos
    purchase_orders.where(:chosen => true)
  end

  def merged_purchasable_items
    po_ids = purchase_orders_categories_templates.pluck(:id)
    bill_ids = bills_categories_templates.pluck(:id)
    r = []
    Item.where('purchase_orders_categories_template_id in (?)  or bills_categories_template_id in (?)', po_ids, bill_ids).group_by(&:name).each do |name, list|
      estimated_cost = list.map(&:amount).compact.sum
      actual_cost = list.map(&:actual_cost).compact.sum
      margin = list.map(&:margin).compact.sum
      r << Item.new(:name => name, :description => list.first.description, :estimated_cost => estimated_cost, :margin => margin, :actual_cost => actual_cost, :purchase_orders_categories_template_id => list.first.purchase_orders_categories_template_id, :bills_categories_template_id => list.first.bills_categories_template_id)
    end
    return r
  end

  def co_items
    template.try(:estimate).try(:project).try(:co_items, category) || Array.new
  end

  def undestroyable?
    bills.select { |i| i.undestroyable? }.any?
  end

  def estimated_amount
    p = self.template.estimate.cost_plus_bid? ? :amount : :price
    items.map(&p).compact.sum
  end

  def revenue_account
    builder = self.template.builder || self.template.estimate.builder
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
    builder = self.template.builder || self.template.estimate.builder
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
      errors[:base] << "This Category Template cannot be deleted once containing items which are added to an invoice"
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
    accounts.each do |account|
      account.destroy if account.has_no_category?
    end
  end

  def destroy_category
    category.destroy unless category.undestroyable?
  end
end
