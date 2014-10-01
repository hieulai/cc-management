# == Schema Information
#
# Table name: receipts
#
#  id                  :integer          not null, primary key
#  builder_id          :integer
#  client_id           :integer
#  method              :string(255)
#  received_at         :date
#  reference           :integer
#  notes               :text
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  remaining_amount    :decimal(10, 2)
#  payor               :string(255)
#  payer_id            :integer
#  payer_type          :string(255)
#  cached_total_amount :decimal(10, 2)
#  kind                :string(255)
#  credit_amount       :decimal(10, 2)
#  deleted_at          :time
#

class Receipt < ActiveRecord::Base
  METHODS = ["Check", "Debit Card", "Wire", "EFT"]
  INVOICED = "Receipt for Invoice"
  UNINVOICED = "Uninvoiced Receipt"
  CLIENT_CREDIT = "Client Credit"

  CLIENT_RECEIPT = "Client Receipt"
  NON_CLIENT_RECEIPT = "Non-Client Receipt"
  TYPES = [["invoiced", INVOICED],
           ["uninvoiced", UNINVOICED],
           ["client_credit", CLIENT_CREDIT],
           ["client_receipt", CLIENT_RECEIPT]]
  NEW_TYPES = [["client_receipt", CLIENT_RECEIPT],
               ["uninvoiced", NON_CLIENT_RECEIPT]]
  NEGATIVES = [Account::ACCOUNTS_RECEIVABLE]
  acts_as_paranoid

  belongs_to :builder, :class_name => "Base::Builder"
  belongs_to :client
  belongs_to :estimate
  belongs_to :payer, polymorphic: true, touch: true
  has_many :receipts_invoices, :dependent => :destroy
  has_many :invoices, :through => :receipts_invoices
  has_many :deposits_receipts, :dependent => :destroy
  has_many :deposits, :through => :deposits_receipts
  has_many :receipts_items, :dependent => :destroy
  has_many :accounting_transactions, as: :transactionable, dependent: :destroy

  attr_accessible :method, :notes, :received_at, :reference, :payer_id, :payer_type, :payor, :client_id,
                  :receipts_invoices_attributes, :remaining_amount, :receipts_items_attributes,
                  :payer_id, :payer_type, :cached_total_amount, :kind, :credit_amount, :job_costed, :estimate_id, :applied_amount
  attr_accessor :applied_amount
  accepts_nested_attributes_for :receipts_invoices, :allow_destroy => true
  accepts_nested_attributes_for :receipts_items, reject_if: :all_blank, allow_destroy: true

  scope :latest, order("received_at DESC")
  scope :unbilled, where('remaining_amount is NULL OR remaining_amount != 0')
  scope :billed, where('remaining_amount = 0')
  scope :date_range, lambda { |from_date, to_date| where('received_at >= ? AND received_at <= ?', from_date, to_date) }

  before_update :check_total_amount_changed, :clear_old_data, :remove_old_transactions
  before_destroy :check_destroyable, :prepend => true
  after_initialize :default_values
  after_save :allocate_invoices, :if => Proc.new { |r| r.client_receipt }
  after_save :update_transactions, :update_remaining_amount
  include Cacheable

  validates_presence_of :builder, :method, :received_at
  validates_presence_of :client, :applied_amount, :if => Proc.new { |r| r.client_receipt }
  validates_presence_of :estimate, :if => Proc.new { |r| r.client_receipt && r.job_costed }
  validates_presence_of :payor, :if => Proc.new { |r| r.uninvoiced }

  searchable do
    integer :reference
    date :received_at
    float :amount do
      amount
    end
    string :notes
    string :method
    string :payer_name do
      payer_name
    end

    text :method, :reference, :notes
    text :received_at_t do |r|
      r.received_at.try(:strftime, Date::DATE_FORMATS[:default])
    end
    text :amount_t do
      sprintf('%.2f', amount.to_f)
    end
    integer :builder_id
    text :payer_name do
      payer_name
    end
  end

  TYPES.each do |t|
    scope t[0].to_sym, where(kind: t[0].to_s)
    define_method("#{t[0]}") do
      return t[0] == self.kind
    end
  end

  def billed?
    self.deposits_receipts.any?
  end

  def date
    received_at
  end

  def amount(opts = {})
    return nil if new_record?
    r = 0
    opts[:credit] ||= true
    if uninvoiced
      r = receipts_items.reject(&:marked_for_destruction?).map(&:amount).compact.sum if receipts_items.any?
    else
      collection = opts[:project_id] ? receipts_invoices.project(opts[:project_id]) : receipts_invoices
      r = collection.reject(&:marked_for_destruction?).map(&:amount).compact.sum if collection.any?
      r += credit_amount.to_f if opts[:credit]
    end
    r.round(2)
  end

  def total_amount
    amount
  end

  def billed_amount
    self.deposits_receipts.map(&:amount).compact.sum if self.deposits_receipts.any?
  end

  def deposit_receipt(deposit_id)
    self.deposits_receipts.where(:deposit_id => deposit_id).first
  end

  def payer_name
    self_payer.try(:display_name)
  end

  def update_transactions
    accounting_transactions.create(account_id: builder.deposits_held_account.id, date: date, amount: amount.to_f)
    accounting_transactions.create(payer_id: self_payer.id, payer_type: self_payer.class.name, date: date, amount: amount.to_f * -1)
    if client_receipt
      opts = {credit: false}
      accounting_transactions.create(account_id: builder.accounts_receivable_account.id, date: date, amount: amount(opts).to_f * -1)
      project_ids = invoices.map { |i| i.project.id }.compact.uniq
      project_ids.each do |project_id|
        opts[:project_id] = project_id
        attrs = {project_id: project_id, date: date, amount: amount(opts).to_f * -1}
        accounting_transactions.create(attrs.merge(payer_id: client.id, payer_type: Client.name))
        accounting_transactions.create(attrs.merge(account_id: builder.deposits_held_account.id))
        accounting_transactions.create(attrs.merge(account_id: builder.accounts_receivable_account.id))
      end
      if credit_amount.to_f > 0
        attrs = {account_id: builder.client_credit_account.id, date: date, amount: credit_amount.to_f, payer_id: client.id, payer_type: Client.name}
        attrs[:project_id] = estimate.project_id if estimate
        accounting_transactions.create attrs
      end
    end
  end

  def remove_old_transactions
    accounting_transactions.destroy_all
  end

  def check_destroyable
    if billed?
      errors[:base] << "This receipt is already paid and can not be modified."
      false
    end
  end

  def check_total_amount_changed
    if !self.new_record? && self.billed? && self.applied_amount!= self.read_attribute(:cached_total_amount)
      errors[:base] << "This receipt has already been paid in the amount of $#{self.read_attribute(:cached_total_amount)}. Editing a paid receipt requires that all item amounts continue to add up to the original deposit amount. If the original deposit was made for the wrong amount, correct the deposit first and then come back and edit the receipt."
      return false
    end
  end

  def update_remaining_amount
    update_column(:remaining_amount, total_amount.to_f - billed_amount.to_f)
  end

  def to_bill_invoices
    return [] unless self.client
    invoices = self.estimate.present? ? self.invoices.estimate(self.estimate.id) : self.invoices.client(self.client_id)
    invoices+= self.estimate.present? ? self.estimate.invoices.unbilled : self.client.invoices.unbilled
    invoices.sort_by! { |i| [i.invoice_date, i.reference] }.uniq!
    invoices
  end

  def allocate_invoices
    applied_amount = (self.applied_amount || self.amount).to_f
    receipts_invoices.destroy_all
    to_bill_invoices.each do |i|
      break if i.full_billed? || applied_amount == 0
      amount = [i.remaining_amount, applied_amount].min
      receipts_invoices.create(invoice_id: i.id, amount: amount)
      applied_amount = (applied_amount- amount).round(2)
    end
    update_column(:credit_amount, applied_amount)
  end

  private
  def default_values
    self.kind ||= "client_receipt"
  end

  def clear_old_data
    if client_receipt
      self.receipts_items.destroy_all
      self.payer = nil
      self.payor = nil
    else
      receipts_invoices.destroy_all
      self.client = nil
      self.job_costed = false
      self.estimate_id = nil
    end
  end

  def self_payer
    uninvoiced ? payer : client
  end
end
