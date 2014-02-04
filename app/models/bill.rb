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
  has_many :un_job_costed_items, :dependent => :destroy

  attr_accessible :purchase_order_id, :remaining_amount, :cached_total_amount, :create_payment, :notes, :builder_id, :project_id, :categories_template_id, :vendor_id, :job_costed, :due_date, :category_id, :bills_items_attributes, :items_attributes, :un_job_costed_items_attributes
  accepts_nested_attributes_for :bills_items, :allow_destroy => true
  accepts_nested_attributes_for :items, :allow_destroy => true
  accepts_nested_attributes_for :un_job_costed_items, :reject_if => :all_blank, :allow_destroy => true
  attr_accessor :create_payment, :category_id

  default_scope order("due_date DESC")
  scope :unpaid, where('remaining_amount is NULL OR remaining_amount > 0')
  scope :paid, where('remaining_amount = 0')

  before_save :check_zero_amount, :check_total_amount_changed
  before_update :clear_old_data
  after_update :destroy_old_purchased_categories_template
  after_destroy :destroy_purchased_categories_template

  validates_presence_of :vendor
  validates_presence_of :project, :categories_template, :if => Proc.new{|b| b.job_costed? }

  def paid?
    self.payments_bills.any?
  end

  def remaining_amount
    unless paid?
      cached_total_amount
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

  def cached_total_amount
     if generated?
       purchase_order.cached_total_amount
     else
       read_attribute(:cached_total_amount)
     end
  end

  def total_amount
    return purchase_order.total_amount if generated?
    if job_costed
      # marked_for_destruction? is used in saving callback
      c_bills_items = bills_items.reject(&:marked_for_destruction?)
      c_items = items.reject(&:marked_for_destruction?)
      if c_bills_items.any? || c_items.any?
        t=0
        t+= c_bills_items.map(&:actual_cost).compact.sum if c_bills_items.any?
        t+= c_items.map(&:actual_cost).compact.sum if c_items.any?
        t
      end
    else
      c_un_job_costed_items = un_job_costed_items.reject(&:marked_for_destruction?)
      t= c_un_job_costed_items.map(&:amount).compact.sum
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
    if self.paid?
      errors[:base] << "This bill is already paid and can not be deleted."
      false
    end
  end

  def check_total_amount_changed
    if !self.new_record? && self.paid? && self.total_amount!= self.cached_total_amount
      errors[:base] << "This bill is already paid and Total amount: $#{cached_total_amount} can not be modified."
      return false
    end
    self.cached_total_amount = self.total_amount
  end

  def check_zero_amount
    if !generated? && total_amount.to_f == 0
      errors[:base] << "Can not save a $0 bill"
      false
    end
  end

  def destroy_old_purchased_categories_template
    return if categories_template_id_was.blank?
    ct = CategoriesTemplate.find(categories_template_id_was)
    ct.destroy if ct.purchased && ct.bills.empty?
  end

  def destroy_purchased_categories_template
    categories_template.destroy if categories_template && categories_template.purchased && categories_template.bills.empty?
  end

  def clear_old_data
    if self.job_costed
      self.un_job_costed_items.destroy_all
    else
      self.items.destroy_all
      self.bills_items.destroy_all
      self.project_id = nil
      self.categories_template_id = nil
    end
  end
end
