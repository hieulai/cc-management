class Receipt < ActiveRecord::Base
  before_destroy :check_readonly

  belongs_to :builder, :class_name => "Base::Builder"
  belongs_to :client
  has_many :receipts_invoices, :dependent => :destroy
  has_many :invoices, :through => :receipts_invoices
  has_many :deposits_receipts, :dependent => :destroy
  has_many :deposits, :through => :deposits_receipts
  has_many :receipts_items, :dependent => :destroy

  attr_accessible :method, :notes, :received_at, :reference, :uninvoiced, :client_id, :create_deposit, :receipts_invoices_attributes, :remaining_amount, :receipts_items_attributes
  accepts_nested_attributes_for :receipts_invoices, :allow_destroy => true
  accepts_nested_attributes_for :receipts_items, reject_if: :all_blank, allow_destroy: true
  attr_accessor :create_deposit

  default_scope order("received_at DESC")
  scope :raw, lambda { |builder_id| where("builder_id = ?", builder_id) }
  scope :unbilled, where('remaining_amount is NULL OR remaining_amount > 0')
  scope :billed, where('remaining_amount = 0')

  before_save :check_readonly
  after_save :clear_old_data

  validates_presence_of :builder, :method
  validates_presence_of :client, :if => Proc.new { |r| !r.uninvoiced? }

  METHODS = ["Check", "Debit Card", "Wire", "EFT"]

  def billed?
    self.deposits_receipts.any?
  end

  def amount
    if self.uninvoiced
      receipts_items.map(&:amount).compact.sum if receipts_items.any?
    else
      receipts_invoices.map(&:amount).compact.sum if receipts_invoices.any?
    end
  end

  def billed_amount
    self.deposits_receipts.map(&:amount).compact.sum if self.deposits_receipts.any?
  end

  def deposit_receipt(deposit_id)
    self.deposits_receipts.where(:deposit_id => deposit_id).first
  end

  def check_readonly
    if billed?
      errors[:base] << "This record is readonly"
      false
    end
  end

  private
  def clear_old_data
    if self.uninvoiced
      self.invoices.destroy_all
    else
      self.receipts_items.destroy_all
    end
  end
end
