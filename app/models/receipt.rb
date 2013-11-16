class Receipt < ActiveRecord::Base
  belongs_to :builder
  belongs_to :account
  belongs_to :client
  has_many :receipts_invoices, :dependent => :destroy
  has_many :invoices, :through => :receipts_invoices
  has_many :deposits_receipts, :dependent => :destroy
  has_many :deposits, :through => :deposits_receipts

  attr_accessible :method, :notes, :received_at, :reference, :client_id, :account_id, :receipts_invoices_attributes, :remaining_amount
  accepts_nested_attributes_for :receipts_invoices, :allow_destroy => true

  default_scope order("received_at DESC")
  scope :unbilled, where('remaining_amount is NULL OR remaining_amount > 0')
  scope :billed, where('remaining_amount = 0')

  validates_presence_of :account, :client, :builder, :method

  METHODS = ["Check", "Debit Card", "Wire", "EFT"]

  def billed?
    self.deposits_receipts.any?
  end

  def amount
    receipts_invoices.map(&:amount).compact.sum if receipts_invoices.any?
  end

  def billed_amount
    self.deposits_receipts.map(&:amount).compact.sum if self.deposits_receipts.any?
  end

  def deposit_receipt(deposit_id)
    self.deposits_receipts.where(:deposit_id => deposit_id).first
  end
end
