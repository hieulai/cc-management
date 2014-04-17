class Payment < ActiveRecord::Base
  acts_as_paranoid
  include Accountable

  belongs_to :builder, :class_name => "Base::Builder"
  belongs_to :account
  belongs_to :vendor
  belongs_to :payer, polymorphic: true
  has_many :payments_bills, :dependent => :destroy

  has_many :bills, :through => :payments_bills

  default_scope order("date DESC")
  scope :date_range, lambda { |from_date, to_date| where('date >= ? AND date <= ?', from_date, to_date) }
  scope :unrecociled, where(:reconciled => false)

  accepts_nested_attributes_for :payments_bills, :allow_destroy => true

  attr_accessible :date, :memo, :method, :reference, :reconciled, :builder_id, :account_id, :vendor_id,
                  :payments_bills_attributes, :payer_id, :payer_type
  validates_presence_of :payer_id, :payer_type, :account, :builder, :method, :date

  after_update :update_account_balance, :if => :account_id_changed?

  METHODS = ["Check", "Debit Card", "Wire", "EFT"]
  NEGATIVES = "*"

  searchable do
    text :reference, :method, :memo
    integer :method
    integer :builder_id
    text :date_t do |p|
      p.date.try(:strftime, Date::DATE_FORMATS[:default])
    end
    text :payer_name do
      payer_name
    end
    text :account_name do
      account_name
    end
  end

  def account_name
    account.try(:name)
  end

  def payer_name
    payer.try(:display_name)
  end

  def amount
    payments_bills.map(&:amount).compact.sum if payments_bills.any?
  end

  def display_priority
    1
  end

  private
  def update_account_balance
    old_account = Account.find(account_id_was)
    account = Account.find(account_id)
    payments_bills.each do |pb|
      old_account.update_attribute(:balance, old_account.balance({recursive: false}).to_f + pb.amount)
      account.update_attribute(:balance, account.balance({recursive: false}).to_f - pb.amount)
    end
  end

end
