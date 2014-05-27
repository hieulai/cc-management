class Bill < ActiveRecord::Base
  acts_as_paranoid
  include Cacheable

  before_destroy :check_readonly

  belongs_to :project
  belongs_to :payer, polymorphic: true
  belongs_to :builder, :class_name => "Base::Builder"
  belongs_to :purchase_order

  has_many :payments_bills, :dependent => :destroy
  has_many :payments, :through => :payments_bills
  has_many :un_job_costed_items, :dependent => :destroy
  has_many :invoices_bills, :dependent => :destroy
  has_many :invoices, :through => :invoices_bills
  has_many :accounting_transactions, as: :transactionable, dependent: :destroy
  has_many :bills_categories_templates, :dependent => :destroy
  has_many :categories_templates, :through => :bills_categories_templates

  attr_accessible :purchase_order_id, :remaining_amount, :cached_total_amount, :create_payment, :notes, :builder_id,
                  :project_id, :job_costed, :due_date, :billed_date,
                  :un_job_costed_items_attributes, :payer_id, :payer_type, :bills_categories_templates_attributes

  accepts_nested_attributes_for :un_job_costed_items, :reject_if => :all_blank, :allow_destroy => true
  accepts_nested_attributes_for :bills_categories_templates, :allow_destroy => true
  attr_accessor :create_payment

  default_scope order("billed_date DESC")
  scope :unpaid, where('remaining_amount is NULL OR remaining_amount > 0')
  scope :paid, where('remaining_amount = 0')
  scope :job_costed, where(job_costed: true)
  scope :date_range, lambda { |from_date, to_date| where('billed_date >= ? AND billed_date <= ?', from_date, to_date) }
  scope :project, lambda { |project_id| where('project_id = ?', project_id) }
  scope :late, lambda { where('remaining_amount != ? AND due_date < ?', 0, Date.today) || joins(:purchase_order).where('purchase_orders.due_date < ?', Date.today) }

  after_initialize :default_values
  before_update :clear_old_data
  before_save :check_zero_amount, :check_total_amount_changed
  after_save :update_transactions

  validates_presence_of :billed_date, :builder
  validates_presence_of :payer_id, :payer_type, :if => Proc.new { |b| b.purchase_order_id.nil? }
  validates_presence_of :project, :if => Proc.new { |b| b.job_costed? && b.purchase_order_id.nil? }

  searchable do
    integer :id
    float :remaining_amount, :trie => true
    integer :purchase_order_id
    integer :builder_id
    date :billed_date
    date :due_date do
      source(:due_date)
    end
    string :project_name do
      project_name
    end
    string :category_names do
      category_names
    end
    string :payer_name do
      payer_name
    end
    string :vnotes do
      vnotes
    end
    float :amount do
      amount
    end

    text :id_t do |b|
      b.id.to_s
    end
    text :amount_t do
      sprintf('%.2f', total_amount.to_f)
    end
    text :purchase_order_id_t do
      purchase_order_id.try(:to_s)
    end
    text :due_date_t do
      source(:due_date).try(:strftime, Date::DATE_FORMATS[:default])
    end
    text :project_name do
      project_name
    end
    text :payer_name do
      payer_name
    end
    text :category_names do
      category_names
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

  def category_names
    if generated?
      purchase_order.category_names
    else
      categories_templates.map { |ct| ct.category.name }.join(",")
    end

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
    paid? && remaining_amount == 0
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
      bills_categories_templates.reject(&:marked_for_destruction?).map(&:amount).compact.sum
    else
      c_un_job_costed_items = un_job_costed_items.reject(&:marked_for_destruction?)
      c_un_job_costed_items.map(&:amount).compact.sum
    end
  end

  def update_transactions
    accounting_transactions.where(account_id: builder.accounts_payable_account.id).first_or_create.update_attributes({date: date, amount: total_amount.to_f})
  end

  def date
    billed_date
  end

  def purchasable_items
    r = []
    bills_categories_templates.each do |b_ct|
      r << b_ct.bills_items
    end
    r.flatten
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

  def clear_old_data
    if self.job_costed
      self.un_job_costed_items.destroy_all
    else
      self.project_id = nil
      self.bills_categories_templates.destroy_all
    end
  end

  def default_values
    self.billed_date ||= Date.today
  end

end
