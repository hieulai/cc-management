class Category < ActiveRecord::Base
  before_destroy :check_destroyable

  belongs_to :builder
  belongs_to :specifications
  has_many :categories_templates, :dependent => :destroy
  has_many :templates, through: :categories_templates
  has_many :items
  
  attr_accessible :name, :cost_total, :margin_total, :price_total, :default, :items_attributes

  accepts_nested_attributes_for :items, reject_if: :all_blank, allow_destroy: true

  # accepts_nested_attributes_for :items, allow_destroy: true

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

  def undestroyable?
    categories_templates.select { |ct| ct.undestroyable? }.any?
  end

  private
  def check_destroyable
    if undestroyable?
      errors[:base] << "Category #{name} cannot be deleted once containing items or change orders which are added to an invoice"
      false
    end
  end
end
