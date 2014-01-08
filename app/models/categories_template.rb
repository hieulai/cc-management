class CategoriesTemplate < ActiveRecord::Base
  before_destroy :check_destroyable, :destroy_items

  attr_accessible :category_id, :template_id, :items_attributes, :purchased

  belongs_to :template
  belongs_to :category
  has_many :purchase_orders, :dependent => :destroy
  has_many :bills, :dependent => :destroy
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

  def co_items
    template.try(:estimate).try(:project).try(:co_items, category) || Array.new
  end

  def undestroyable?
    items.select { |i| i.billed? }.any? || co_items.select { |i| i.billed? }.any?
  end

  def destroy_with_associations
    items.each do |i|
      i.destroy
    end
    category.destroy if category.present?
    purchase_orders.each do |po|
      if po.bill
        po.bill.payments_bills.destroy_all
        po.bill.destroy
      end
      po.destroy
    end
    bills.each do |b|
      b.payments_bills.destroy_all
      b.destroy
    end
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
end
