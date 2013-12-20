class PurchaseOrder < ActiveRecord::Base

  before_destroy :check_readonly

  belongs_to :project
  belongs_to :vendor
  belongs_to :categories_template
  belongs_to :builder, :class_name => "Base::Builder"
  has_many :items, :dependent => :destroy
  has_one :bill, :dependent => :destroy
  has_many :purchase_orders_items, :dependent => :destroy
  serialize :amount

  default_scope order("date DESC")

  attr_accessible :chosen, :sales_tax_rate, :shipping, :date, :notes, :builder_id, :project_id, :categories_template_id, :vendor_id, :due_date, :category_id, :purchase_orders_items_attributes
  accepts_nested_attributes_for :purchase_orders_items, :allow_destroy => true
  attr_accessor :category_id

  after_initialize :default_values
  before_save :check_readonly
  after_save :create_bill

  validates_presence_of :vendor, :project, :categories_template

  def has_bill_paid?
    bill.try(:paid?)
  end

  def has_bill_full_paid?
    bill.try(:full_paid?)
  end

  def total_amount
    if self.shipping || purchase_orders_items.any? || items.any?
      t =0
      t+= self.shipping||0
      t+= purchase_orders_items.map(&:actual_cost).compact.sum if purchase_orders_items.any?
      t+= items.map(&:actual_cost).compact.sum if items.any?
      t.round(2)
    end
  end

  def purchasable_item(item_id)
    purchase_orders_items.where(:item_id => item_id).first
  end

  def purchasable_items
    purchase_orders_items
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
