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
    pos_empty = purchase_orders.where(:chosen => true).first.try(:items).try(:map, &attr).try(:compact).blank?
    cos_empty = true
    if [:committed_cost, :committed_profit].include? attr
      cos_empty = change_orders.map(&attr).compact.blank?
    end
    return nil if  items_empty && cos_empty && pos_empty
    total= items.map(&attr).compact.sum
    total+= co(attr) if [:committed_cost, :committed_profit].include? attr
    total+= purchase_orders.where(:chosen => true).first.try(:items).try(:map, &attr).try(:compact).try(:sum).to_f
  end

  def co(attr)
    change_orders.map(&attr).compact.sum
  end

  before_destroy do
    items.destroy_all
  end
end
