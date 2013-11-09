class Invoice < ActiveRecord::Base
  belongs_to :builder
  belongs_to :estimate
  has_many :invoices_items, :dependent => :destroy
  has_many :items, :through => :invoices_items

  default_scope order("created_at DESC")

  accepts_nested_attributes_for :invoices_items, :allow_destroy => true, reject_if: :unbillable_item
  attr_accessible :reference, :sent_date, :estimate_id, :invoices_items_attributes

  validates_presence_of :estimate, :builder

  def amount
    invoices_items.map(&:amount).compact.sum if invoices_items.any?
  end

  private
  def unbillable_item(attributes)
    attributes['item_id'].blank? || !Item.find(attributes['item_id'].to_i).billable?(self.id)
  end
end
