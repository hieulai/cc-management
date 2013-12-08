class PurchaseOrder < ActiveRecord::Base
  include Purchasable

  before_destroy :check_readonly

  has_one :bill, :dependent => :destroy

  default_scope order("date DESC")

  attr_accessible :chosen, :sales_tax_rate, :shipping, :date

  after_initialize :default_values

  validates_presence_of :categories_template, :project

  before_save :check_readonly
  after_save :create_bill

  def has_bill_paid?
    bill.try(:paid?)
  end

  def has_bill_full_paid?
    bill.try(:full_paid?)
  end

  def total_amount
    t=0
    self.shipping||=0
    amount.each do |i|
      t+= i[:actual_cost].to_f
    end
    t+= items.map(&:actual_cost).compact.sum + self.shipping
    t.round(2)
  end

  private
  def default_values
    self.chosen ||= true
    self.sales_tax_rate||=8.25
  end

  def create_bill
    unless bill.present?
      Bill.create!(:purchase_order_id => self.id,
                   :builder_id => self.builder_id,
                   :vendor_id => self.vendor_id,
                   :project_id => self.project_id,
                   :categories_template_id => self.categories_template_id)
    end
  end

  def check_readonly
    if has_bill_paid?
      errors[:base] << "This purchase order is already paid and can not be modified."
      false
    end
  end
end
