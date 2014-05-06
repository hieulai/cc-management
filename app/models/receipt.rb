class Receipt < ActiveRecord::Base
  before_destroy :check_readonly

  belongs_to :builder, :class_name => "Base::Builder"
  belongs_to :client
  belongs_to :payer, polymorphic: true
  has_many :receipts_invoices, :dependent => :destroy
  has_many :invoices, :through => :receipts_invoices
  has_many :deposits_receipts, :dependent => :destroy
  has_many :deposits, :through => :deposits_receipts
  has_many :receipts_items, :dependent => :destroy
  has_many :accounting_transactions, as: :transactionable, dependent: :destroy

  attr_accessible :method, :notes, :received_at, :reference, :uninvoiced, :payer_id, :payer_type, :payor, :client_id, :reconciled,
                  :account_type, :create_deposit, :receipts_invoices_attributes, :remaining_amount, :receipts_items_attributes,
                  :payer_id, :payer_type, :cached_total_amount
  accepts_nested_attributes_for :receipts_invoices, :allow_destroy => true
  accepts_nested_attributes_for :receipts_items, reject_if: :all_blank, allow_destroy: true
  attr_accessor :create_deposit, :account_type

  default_scope order("received_at DESC")
  scope :unbilled, where('remaining_amount is NULL OR remaining_amount > 0')
  scope :uninvoiced, where(uninvoiced: true)
  scope :invoiced, where(uninvoiced: false)
  scope :billed, where('remaining_amount = 0')
  scope :date_range, lambda { |from_date, to_date| where('received_at >= ? AND received_at <= ?', from_date, to_date) }

  before_save :check_total_amount_changed, :clear_old_data
  after_save :update_transactions

  validates_presence_of :builder, :method, :received_at
  validates_presence_of :client, :if => Proc.new { |r| !r.uninvoiced? }
  validates_presence_of :payor, :if => Proc.new { |r| r.uninvoiced? }

  METHODS = ["Check", "Debit Card", "Wire", "EFT"]
  NEGATIVES = [Account::ACCOUNTS_RECEIVABLE]

  searchable do
    text :method, :reference, :notes
    text :received_at_t do |r|
      r.received_at.try(:strftime, Date::DATE_FORMATS[:default])
    end
    integer :builder_id
    text :payer_name do
      payer_name
    end
  end

  def billed?
    self.deposits_receipts.any?
  end

  def date
    received_at
  end

  def amount
    if self.uninvoiced
      receipts_items.reject(&:marked_for_destruction?).map(&:amount).compact.sum if receipts_items.any?
    else
      receipts_invoices.reject(&:marked_for_destruction?).map(&:amount).compact.sum if receipts_invoices.any?
    end
  end

  def billed_amount
    self.deposits_receipts.map(&:amount).compact.sum if self.deposits_receipts.any?
  end

  def deposit_receipt(deposit_id)
    self.deposits_receipts.where(:deposit_id => deposit_id).first
  end

  def payer_name
    uninvoiced ? payor : client.try(:full_name)
  end

  def check_readonly
    if billed?
      errors[:base] << "This receipt is already paid and can not be modified."
      false
    end
  end

  def check_total_amount_changed
    if !self.new_record? && self.billed? && self.amount!= self.read_attribute(:cached_total_amount)
      errors[:base] << "This receipt has already been paid in the amount of $#{self.read_attribute(:cached_total_amount)}. Editing a paid receipt requires that all item amounts continue to add up to the original deposit amount. If the original deposit was made for the wrong amount, correct the deposit first and then come back and edit the receipt."
      return false
    end
  end

  private
  def clear_old_data
    if self.uninvoiced
      self.receipts_invoices.destroy_all
      self.client = nil
    else
      self.receipts_items.destroy_all
      self.payer = nil
      self.payor = nil
    end
  end

  def update_transactions
    accounting_transactions.where(account_id: builder.deposits_held_account.id).first_or_create.update_attributes({date: date, amount: amount.to_f})
    if uninvoiced
      accounting_transactions.where(account_id: builder.accounts_receivable_account.id).destroy_all
    else
      accounting_transactions.where(account_id: builder.accounts_receivable_account.id).first_or_create.update_attributes({date: date, amount: amount.to_f * -1})
    end
  end
end
