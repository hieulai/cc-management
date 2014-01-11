class Bill < ActiveRecord::Base
  before_destroy :check_readonly

  belongs_to :project
  belongs_to :vendor
  belongs_to :categories_template
  belongs_to :builder, :class_name => "Base::Builder"
  belongs_to :purchase_order
  has_many :items, :dependent => :destroy
  has_many :payments_bills, :dependent => :destroy
  has_many :payments, :through => :payments_bills
  has_many :bills_items, :dependent => :destroy

  attr_accessible :purchase_order_id, :remaining_amount, :create_payment, :notes, :builder_id, :project_id, :categories_template_id, :vendor_id, :due_date, :category_id, :bills_items_attributes
  accepts_nested_attributes_for :bills_items, :allow_destroy => true
  attr_accessor :create_payment, :category_id

  default_scope order("due_date DESC")
  scope :raw, lambda { |builder_id| where("builder_id = ?", builder_id) }
  scope :unpaid, where('remaining_amount is NULL OR remaining_amount > 0')
  scope :paid, where('remaining_amount = 0')

  before_save :check_readonly
  after_update :destroy_old_purchased_categories_template
  after_destroy :destroy_purchased_categories_template

  validates_presence_of :vendor, :project, :categories_template

  def paid?
    self.payments_bills.any?
  end

  def remaining_amount
    unless paid?
      total_amount
    else
      read_attribute(:remaining_amount)
    end
  end

  def full_paid?
     self.remaining_amount == 0
  end

  def late?
    !full_paid? && !source(:due_date).nil? && source(:due_date) < Date.today
  end

  def paid_status
    case
      when late?
        'Late'
      when full_paid?
        'Paid'
      else
        'Unpaid'
    end
  end

  def generated?
    self.purchase_order.present?
  end

  def source(attr)
    if self.purchase_order.present?
      purchase_order.try(attr)
    else
      self.try(attr)
    end
  end

  def paid_amount
    self.payments_bills.map(&:amount).compact.sum if self.payments_bills.any?
  end

  def payment_bill(payment_id)
    self.payments_bills.where(:payment_id => payment_id).first
  end

  def total_amount
    return purchase_order.total_amount if generated?
    if bills_items.any? || items.any?
      t=0
      t+= bills_items.map(&:actual_cost).compact.sum if bills_items.any?
      t+= items.map(&:actual_cost).compact.sum if items.any?
      t
    end
  end

  def purchasable_item(item_id)
    bills_items.where(:item_id => item_id).first
  end

  def purchasable_items
    bills_items
  end

  private

  def check_readonly
    if paid?
      errors[:base] << "This bill is already paid and can not be modified."
      false
    end
  end

  def destroy_old_purchased_categories_template
    ct = CategoriesTemplate.find(categories_template_id_was)
    ct.destroy if ct.purchased && ct.bills.empty?
  end

  def destroy_purchased_categories_template
    categories_template.destroy if categories_template && categories_template.purchased && categories_template.bills.empty?
  end

end
