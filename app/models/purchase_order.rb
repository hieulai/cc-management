class PurchaseOrder < ActiveRecord::Base
  include Purchasable

  has_one :bill, :dependent => :destroy

  attr_accessible :chosen, :sales_tax_rate, :shipping, :date

  after_initialize :default_values

  validates_presence_of :categories_template, :project

  after_save :create_bill

  before_destroy :raise_readonly

  def readonly?
    bill.try(:paid)
  end

  def total_amount
    t=0
    self.shipping||=0
    amount.each do |i|
      t+= i[:actual_cost].to_f
    end
    t + items.map(&:actual_cost).compact.sum + self.shipping
  end

  private
  def default_values
    self.chosen ||= true
    self.sales_tax_rate||=8.25
  end

  def create_bill
    unless bill.present?
      Bill.create!(:purchase_order_id => self.id, :builder_id => self.builder_id, :vendor_id => self.vendor_id)
    end
  end

  def raise_readonly
    raise ActiveRecord::ReadOnlyRecord if self.readonly?
  end
end
