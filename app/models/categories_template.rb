class CategoriesTemplate < ActiveRecord::Base
  attr_accessible :category_id, :template_id, :items_attributes

  belongs_to :template
  belongs_to :category
  has_many :bids, :dependent => :delete_all
  has_many :purchase_orders, :dependent => :delete_all
  has_many :change_orders, :dependent => :delete_all
  has_and_belongs_to_many :items
  accepts_nested_attributes_for :items, allow_destroy: true

  def category_name
    self.category.name
  end

  def total(attr)
    items_empty = items.map(&attr).compact.blank?
    pos_empty = po.try(:items).try(:map, &attr).try(:compact).blank? && po.try(:shipping).blank?
    cos_empty = true
    if [:committed_cost, :committed_profit].include? attr
      cos_empty = change_orders.map(&attr).compact.blank?
    end
    return nil if  items_empty && cos_empty && pos_empty
    total= items.map(&attr).compact.sum
    total+= co(attr) if [:committed_cost, :committed_profit].include? attr
    total+= po.try(:items).try(:map, &attr).try(:compact).try(:sum).to_f

    if :actual_cost == attr
      total+= po.shipping.to_f
    elsif :actual_profit == attr
      total-= po.shipping.to_f
    end
  end

  def co(attr)
    change_orders.map(&attr).compact.sum
  end

  def po
    purchase_orders.where(:chosen => true).first
  end

  before_destroy do
    items.destroy_all
  end
end
