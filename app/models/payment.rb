class Payment < ActiveRecord::Base

  belongs_to :builder, :class_name => "Base::Builder"
  belongs_to :account
  belongs_to :vendor
  has_many :payments_bills, :dependent => :destroy

  has_many :bills, :through => :payments_bills

  default_scope order("date DESC")

  accepts_nested_attributes_for :payments_bills, :allow_destroy => true
  
  attr_accessible :date, :memo, :method, :reference, :reconciled , :builder_id, :account_id, :vendor_id, :payments_bills_attributes

  validates_presence_of :vendor, :account, :builder, :method, :date

  after_update :update_account_balance, :if => :account_id_changed?

  METHODS = ["Check", "Debit Card", "Wire", "EFT"]

  def amount
    payments_bills.map(&:amount).compact.sum if payments_bills.any?
  end

  def payee
    vendor.try(:display_name)
  end

  private
  def update_account_balance
    old_account = Account.find(account_id_was)
    account = Account.find(account_id)
    payments_bills.each do |pb|
      old_account.update_attribute(:balance, old_account.balance + pb.amount)
      account.update_attribute(:balance, account.balance - pb.amount)
    end
  end

end
