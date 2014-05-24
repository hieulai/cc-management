class Category < ActiveRecord::Base
  before_destroy :check_destroyable

  belongs_to :builder, :class_name => "Base::Builder"
  belongs_to :specifications
  has_many :categories_templates, :dependent => :destroy
  has_many :change_orders_categories, :dependent => :destroy
  has_many :templates, through: :categories_templates
  has_many :bids, :dependent => :destroy
  
  attr_accessible :name, :cost_total, :margin_total, :price_total, :default, :items_attributes

  default_scope order("name ASC")
  scope :raw, where(template_id: nil)

  after_save :update_indexes

  validates :name, presence: true

  def destroy_with_associations
    return false if check_destroyable == false
    categories_templates.each do |ct|
      ct.items.each do |i|
        i.destroy
      end
    end
    destroy
  end

  def raw?
    template_id.nil? && builder_id
  end

  def undestroyable?
    categories_templates.select { |ct| ct.undestroyable? }.any?
  end

  private
  def check_destroyable
    if undestroyable?
      errors[:invoice] << "Category #{name} cannot be deleted once containing items or change orders which are added to an invoice"
      false
    end
  end

  def update_indexes
    categories_templates.each do |ct|
      ct.update_indexes
    end
  end
end
