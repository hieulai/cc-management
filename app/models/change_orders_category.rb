class ChangeOrdersCategory < ActiveRecord::Base
  before_destroy :check_destroyable

  belongs_to :change_order
  belongs_to :category
  has_many :items, :dependent => :delete_all
  attr_accessible :category_id, :change_order_id, :items_attributes
  accepts_nested_attributes_for :items, allow_destroy: true

  def amount
    items.map(&:price).compact.sum
  end

  def undestroyable?
    items.select { |i| i.billed? }.any?
  end

  private
  def check_destroyable
    if self.undestroyable?
      errors[:invoice] << "Change Order Category #{id} cannot be deleted once containing items which are added to an invoice"
      false
    end
  end
end
