class Bid < ActiveRecord::Base

  belongs_to :project
  belongs_to :vendor
  belongs_to :category
  has_many :bids_items, :dependent => :destroy

  validates_presence_of :category

  attr_accessible :amount, :notes, :chosen, :vendor_id, :category_id, :bids_items_attributes
  accepts_nested_attributes_for :bids_items, :allow_destroy => true

  serialize :amount

  def total_amount
    bids_items.map(&:amount).compact.sum if bids_items.any?
  end

  def item_amount(item_id)
    bids_items.where(:item_id => item_id).first.try(:amount)
  end

  def items
    categories_template.try(:items)
  end

  def co_items
    if categories_template
      categories_template.co_items
    elsif category
      project.co_items(category)
    end
  end

  private
  def categories_template
    CategoriesTemplate.where(:category_id => category_id, :template_id => project.estimates.first.template.id).first
  end
end
