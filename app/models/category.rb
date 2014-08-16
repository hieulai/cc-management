class Category < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :builder, :class_name => "Base::Builder"
  has_many :categories_templates, :dependent => :destroy
  has_many :change_orders_categories, :dependent => :destroy
  has_many :templates, through: :categories_templates
  has_many :bids, :dependent => :destroy
  
  attr_accessible :name, :cost_total, :margin_total, :price_total, :default, :items_attributes

  default_scope order("name ASC")
  scope :raw, where(template_id: nil)

  before_destroy :check_destroyable, :prepend => true
  after_save :update_indexes

  validates :name, presence: true

  def raw?
    template_id.nil? && builder_id
  end

  def has_billed_categories?
    categories_templates.select { |ct| ct.undestroyable? }.any?
  end

  def has_billed_change_orders?
    change_orders_categories.select { |ct| ct.undestroyable? }.any?
  end

  def has_chosen_bids?
    bids.chosen.any?
  end

  def undestroyable?
    has_billed_categories? || has_billed_change_orders? || has_chosen_bids?
  end

  private
  def check_destroyable
    if undestroyable?
      errors[:base] << "This Category contains items which are added to an invoice" if has_billed_categories? || has_billed_change_orders?
      errors[:base] << "This Category contains commited bids" if has_chosen_bids?
      false
    end
  end

  def update_indexes
    categories_templates.each do |ct|
      ct.update_indexes
    end
  end
end
