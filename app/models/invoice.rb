class Invoice < ActiveRecord::Base
  before_destroy :check_readonly

  belongs_to :builder, :class_name => "Base::Builder"
  belongs_to :estimate
  has_many :invoices_items, :dependent => :destroy
  has_many :items, :through => :invoices_items
  has_many :invoices_bills, :dependent => :destroy
  has_many :bills, :through => :invoices_bills
  has_many :receipts_invoices, :dependent => :destroy
  has_many :receipts, :through => :receipts_invoices

  accepts_nested_attributes_for :invoices_items, :allow_destroy => true, reject_if: :unbillable_item
  accepts_nested_attributes_for :invoices_bills, :allow_destroy => true, reject_if: :unbillable_bill
  attr_accessible :reference, :sent_date, :invoice_date, :estimate_id, :invoices_items_attributes, :invoices_bills_attributes, :remaining_amount,
                  :reconciled, :bill_from_date, :bill_to_date
  attr_accessor :account_amount, :related_account
  default_scope order("created_at DESC")
  scope :unbilled, where('remaining_amount is NULL OR remaining_amount > 0')
  scope :billed, where('remaining_amount = 0')
  scope :date_range, lambda { |from_date, to_date| where('invoice_date >= ? AND invoice_date <= ?', from_date, to_date) }
  scope :project, lambda { |project_id| joins(:estimate).where('estimates.project_id = ?', project_id) }

  after_initialize :default_values
  before_save :check_readonly, :check_reference
  before_update :clear_old_data

  validates_presence_of :estimate, :builder

  searchable do
    date :invoice_date
    date :sent_date
    integer :builder_id
    text :reference
    text :id_t do |i|
      i.id.to_s
    end
    text :sent_date_t do |i|
      i.sent_date.try(:strftime, Date::DATE_FORMATS[:default])
    end
    text :invoice_date_t do |i|
      i.invoice_date.try(:strftime, Date::DATE_FORMATS[:default])
    end
    text :project_name do
      project_name
    end
  end

  def project_name
    estimate.try(:project).try(:name)
  end

  def billed?
    self.receipts_invoices.any?
  end

  def amount
    if invoices_items.any?
      invoices_items.map(&:amount).compact.sum
    elsif invoices_bills.any?
      invoices_bills.map(&:amount).compact.sum
    end
  end

  def billed_amount
    self.receipts_invoices.map(&:amount).compact.sum if self.receipts_invoices.any?
  end

  def receipt_invoice(receipt_id)
    self.receipts_invoices.where(:receipt_id => receipt_id).first
  end

  def date
    invoice_date
  end

  def display_priority
    1
  end

  private
  def unbillable_item(attributes)
    attributes['item_id'].blank? || !Item.find(attributes['item_id'].to_i).billable?(self.id)
  end

  def unbillable_bill(attributes)
    attributes['bill_id'].blank? || !Bill.find(attributes['bill_id'].to_i).billable?(self.id)
  end

  def check_readonly
    if billed?
      errors[:base] << "This record is readonly"
      false
    end
  end

  def check_reference
    if self.reference
      return true unless reference_changed?
      if self.class.where('id != ? and reference = ?', id, reference).any?
        errors[:base] << "Invoice # #{reference} is already used"
        return false
      end
    else
      self.reference = self.class.maximum(:reference).to_f + 1
    end
  end

  def clear_old_data
    if self.estimate.cost_plus_bid?
      self.invoices_items.destroy_all
    else
      self.invoices_bills.destroy_all
      self.bill_from_date = nil
      self.bill_to_date = nil
    end
  end

  def default_values
    self.invoice_date ||= Date.today
  end
end
