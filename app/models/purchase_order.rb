class PurchaseOrder < ActiveRecord::Base

  before_destroy :check_readonly

  belongs_to :project
  belongs_to :vendor
  belongs_to :payer, polymorphic: true
  belongs_to :builder, :class_name => "Base::Builder"
  has_many :items, :dependent => :destroy
  has_one :bill, :dependent => :destroy
  has_many :purchase_orders_items, :dependent => :destroy
  has_many :purchase_orders_categories_templates, :dependent => :destroy
  has_many :categories_templates, :through => :purchase_orders_categories_templates

  default_scope order("date DESC")

  attr_accessible :chosen, :sales_tax_rate, :shipping, :date, :notes, :cached_total_amount, :builder_id, :project_id,
                  :vendor_id, :due_date, :purchase_orders_items_attributes, :items_attributes,
                  :payer_id, :payer_type, :purchase_orders_categories_templates_attributes, :categories_template_id
  accepts_nested_attributes_for :purchase_orders_items, :allow_destroy => true
  accepts_nested_attributes_for :items, :allow_destroy => true
  accepts_nested_attributes_for :purchase_orders_categories_templates, :allow_destroy => true

  after_initialize :default_values
  before_save :check_zero_amount, :check_total_amount_changed
  after_save :create_default_bill, :update_indexes

  validates_presence_of :payer_id, :payer_type, :project

  searchable do
    integer :id
    integer :builder_id
    date :date
    float :amount do
      total_amount
    end
    string :notes
    string :project_name do
      project_name
    end
    string :payer_name do
      payer_name
    end
    string :category_names do
      category_names
    end

    text :notes
    text :id_t do |po|
      po.id.to_s
    end
    text :amount_t do
      sprintf('%.2f', total_amount.to_f)
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
    text :category_names do
      category_names
    end
  end

  def project_name
    project.try(:name)
  end

  def payer_name
    payer.try(:display_name)
  end

  def category_names
    categories_templates.map { |ct| ct.category.name }.join(", ")
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
    purchase_orders_categories_templates.reject(&:marked_for_destruction?).map(&:amount).compact.sum + shipping.to_f
  end

  def purchasable_items
    r = []
    purchase_orders_categories_templates.each do |p_ct|
      r << p_ct.purchase_orders_items
    end
    r.flatten
  end

  private
  def default_values
    self.chosen ||= true
    self.sales_tax_rate||=8.25
  end

  def create_default_bill
    self.create_bill({:purchase_order_id => self.id, :builder_id => self.builder_id}) unless bill
    bill.update_attributes({:payer_id => payer_id, :payer_type => payer_type})
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
    Sunspot.delay.index bill
  end
end
