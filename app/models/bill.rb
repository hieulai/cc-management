class Bill < ActiveRecord::Base
  acts_as_paranoid
  include Accountable
  include Invoiceable

  before_destroy :check_readonly

  belongs_to :project
  belongs_to :vendor
  belongs_to :payer, polymorphic: true
  belongs_to :categories_template
  belongs_to :builder, :class_name => "Base::Builder"
  belongs_to :purchase_order
  has_many :items, :dependent => :destroy
  has_many :payments_bills, :dependent => :destroy
  has_many :payments, :through => :payments_bills
  has_many :bills_items, :dependent => :destroy
  has_many :un_job_costed_items, :dependent => :destroy
  has_many :invoices_bills, :dependent => :destroy
  has_many :invoices, :through => :invoices_bills

  attr_accessible :purchase_order_id, :remaining_amount, :cached_total_amount, :create_payment, :notes, :builder_id,
                  :project_id, :categories_template_id, :vendor_id, :job_costed, :due_date, :billed_date, :reconciled,
                  :category_id, :bills_items_attributes, :items_attributes, :un_job_costed_items_attributes,
                  :payer_id, :payer_type
  accepts_nested_attributes_for :bills_items, :allow_destroy => true
  accepts_nested_attributes_for :items, :allow_destroy => true
  accepts_nested_attributes_for :un_job_costed_items, :reject_if => :all_blank, :allow_destroy => true
  attr_accessor :create_payment, :category_id

  default_scope order("due_date DESC")
  scope :unpaid, where('remaining_amount is NULL OR remaining_amount > 0')
  scope :paid, where('remaining_amount = 0')
  scope :job_costed, where(job_costed: true)
  scope :date_range, lambda { |from_date, to_date| where('billed_date >= ? AND billed_date <= ?', from_date, to_date) }
  scope :project, lambda { |project_id| where('project_id = ?', project_id) }
  scope :late, lambda { where('remaining_amount != ? AND due_date < ?', 0, Date.today) || joins(:purchase_order).where('purchase_orders.due_date < ?', Date.today) }
  scope :unrecociled, where(:reconciled => false)

  after_initialize :default_values
  before_save :check_zero_amount, :check_total_amount_changed, :decrease_account, :increase_account
  before_update :clear_old_data
  after_update :destroy_old_purchased_categories_template
  after_destroy :decrease_account, :destroy_purchased_categories_template

  validates_presence_of :payer_id, :payer_type, :billed_date, :builder
  validates_presence_of :project, :categories_template, :if => Proc.new { |b| b.job_costed? }
  NEGATIVES = []

  searchable do
    integer :id
    integer :remaining_amount
    integer :purchase_order_id
    integer :builder_id
    date :due_date
    date :po_due_date do |b|
      b.purchase_order.try(:due_date)
    end
    text :id_t do |b|
      b.id.to_s
    end
    text :purchase_order_id_t do |b|
      b.purchase_order_id.try(:to_s)
    end
    text :due_date_t do
      source(:due_date).try(:strftime, Date::DATE_FORMATS[:default])
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
    text :vnotes do
      vnotes
    end
  end

  def project_name
    self.source(:project).try(:name)
  end

  def payer_name
    self.source(:payer).try(:display_name)
  end

  def category_name
    self.source(:categories_template).try(:category).try(:name)
  end

  def vnotes
    self.source(:notes)
  end

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

  def amount
    cached_total_amount
  end

  def price
    cached_total_amount
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

  def increase_account
    return unless job_costed
    category_template = CategoriesTemplate.find(categories_template_id)
    category_template.cogs_account.update_column(:balance, category_template.cogs_account.balance({recursive: false}).to_f + self.total_amount.to_f)
    builder.accounts_payable_account.update_column(:balance, builder.accounts_payable_account.balance({recursive: false}).to_f + self.total_amount.to_f)
  end

  def decrease_account
    return unless job_costed && categories_template_id_was
    category_template_was = CategoriesTemplate.find(categories_template_id_was)
    category_template_was.cogs_account.update_column(:balance, category_template_was.cogs_account.balance({recursive: false}).to_f - self.read_attribute(:cached_total_amount).to_f)
    builder.accounts_payable_account.update_column(:balance, builder.accounts_payable_account.balance({recursive: false}).to_f - self.read_attribute(:cached_total_amount).to_f)
  end

  def date
    billed_date
  end

  def display_priority
    1
  end

  private
  def check_readonly
    if self.paid?
      errors[:base] << "This bill is already paid and can not be deleted."
      false
    end
  end

  def check_total_amount_changed
    if !self.new_record? && self.paid? && self.total_amount!= self.read_attribute(:cached_total_amount)
      errors[:base] << "This bill has already been paid in the amount of $#{self.read_attribute(:cached_total_amount)}. Editing a paid bill requires that all item amounts continue to add up to the original payment amount. If the original payment was made for the wrong amount, correct the payment first and then come back and edit the bill."
      return false
    end
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

  def default_values
    self.billed_date ||= Date.today
  end

end
