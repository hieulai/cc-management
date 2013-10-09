class CategoriesTemplate < ActiveRecord::Base
  attr_accessible :category_id, :template_id, :items_attributes

  belongs_to :template
  belongs_to :category
  has_many :bids, :dependent => :delete_all
  has_many :purchase_orders, :dependent => :delete_all
  has_many :bills, :dependent => :delete_all
  has_and_belongs_to_many :items
  accepts_nested_attributes_for :items, allow_destroy: true

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

  before_destroy do
    items.destroy_all
  end
end
