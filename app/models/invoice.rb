class Invoice < ActiveRecord::Base
  before_destroy :check_readonly

  belongs_to :builder, :class_name => "Base::Builder"
  belongs_to :estimate
  has_many :invoices_items, :dependent => :destroy
  has_many :items, :through => :invoices_items
  has_many :receipts_invoices, :dependent => :destroy
  has_many :receipts, :through => :receipts_invoices

  accepts_nested_attributes_for :invoices_items, :allow_destroy => true, reject_if: :unbillable_item
  attr_accessible :reference, :sent_date, :invoice_date, :estimate_id, :invoices_items_attributes, :remaining_amount

  default_scope order("created_at DESC")
  scope :raw, lambda { |builder_id| where("builder_id = ?", builder_id) }
  scope :unbilled, where('remaining_amount is NULL OR remaining_amount > 0')
  scope :billed, where('remaining_amount = 0')

  before_save :check_readonly, :check_reference

  validates_presence_of :estimate, :builder

  def billed?
    self.receipts_invoices.any?
  end

  def invoice_date
    read_attribute(:invoice_date) || created_at
  end

  def amount
    invoices_items.map(&:amount).compact.sum if invoices_items.any?
  end

  def billed_amount
    self.receipts_invoices.map(&:amount).compact.sum if self.receipts_invoices.any?
  end

  def receipt_invoice(receipt_id)
    self.receipts_invoices.where(:receipt_id => receipt_id).first
  end

  private
  def unbillable_item(attributes)
    attributes['item_id'].blank? || !Item.find(attributes['item_id'].to_i).billable?(self.id)
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
end
