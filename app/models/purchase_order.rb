class PurchaseOrder < ActiveRecord::Base

  before_destroy :check_readonly

  belongs_to :project
  belongs_to :vendor
  belongs_to :payer, polymorphic: true
  belongs_to :categories_template
  belongs_to :builder, :class_name => "Base::Builder"
  has_many :items, :dependent => :destroy
  has_one :bill, :dependent => :destroy
  has_many :purchase_orders_items, :dependent => :destroy

  default_scope order("date DESC")

  attr_accessible :chosen, :sales_tax_rate, :shipping, :date, :notes, :cached_total_amount , :builder_id, :project_id,
                  :categories_template_id, :vendor_id, :due_date, :category_id, :purchase_orders_items_attributes, :items_attributes,
                  :payer_id, :payer_type
  accepts_nested_attributes_for :purchase_orders_items, :allow_destroy => true
  accepts_nested_attributes_for :items, :allow_destroy => true
  attr_accessor :category_id

  after_initialize :default_values
  before_save :check_zero_amount, :check_total_amount_changed
  after_save :create_bill, :update_indexes

  validates_presence_of :payer_id, :payer_type, :project, :categories_template

  searchable do
    text :notes
    integer :id
    integer :builder_id
    text :id_t do |po|
      po.id.to_s
    end
    text :date_t do |po|
      po.date.try(:strftime, Date::DATE_FORMATS[:default])
    end
    text :project_names do
      project_name
    end
    text :payer_name do
      payer_name
    end
    text :category_name do
      category_name
    end
  end

  def project_name
    project.try(:name)
  end

  def payer_name
    payer.try(:display_name)
  end

  def category_name
    categories_template.try(:category).try(:name)
  end

  def has_bill_paid?
    bill.try(:paid?)
  end

  def has_bill_full_paid?
    bill.try(:full_paid?)
  end

  def cached_total_amount
    read_attribute(:cached_total_amount).to_f + self.shipping.to_f
  end

  def total_amount
    c_po_items = purchase_orders_items.reject(&:marked_for_destruction?)
    c_items = items.reject(&:marked_for_destruction?)
    if self.shipping || c_po_items.any? || c_items.any?
      t =0
      t+= self.shipping.to_f
      t+= c_po_items.map(&:actual_cost).compact.sum if c_po_items.any?
      t+= c_items.map(&:actual_cost).compact.sum if c_items.any?
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
    unless PurchaseOrder.find(self.id).bill
      Bill.create!(:purchase_order_id => self.id,
                   :builder_id => self.builder_id,
                   :payer_id => self.payer_id,
                   :payer_type => self.payer_type,
                   :project_id => self.project_id,
                   :categories_template_id => self.categories_template_id)
    end
  end

  def check_readonly
    if has_bill_paid?
      errors[:base] << "This purchase order is already paid and can not be deleted."
      false
    end
  end

  def check_zero_amount
    if total_amount.to_f == 0
      errors[:base] << "Can not save a $0 Purchase order"
      false
    end
  end

  def check_total_amount_changed
    if !self.new_record? && self.has_bill_paid? && self.total_amount!= self.cached_total_amount
      errors[:base] << "This purchase order has bill #{bill.id} which has already been paid in the amount of $#{cached_total_amount}. Editing a paid bill requires that all item amounts continue to add up to the original payment amount. If the original payment was made for the wrong amount, correct the payment first and then come back and edit the bill."
      return false
    end
  end

  def update_indexes
    Sunspot.index bill
  end
end
