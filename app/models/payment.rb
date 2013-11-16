class Payment < ActiveRecord::Base

  belongs_to :builder
  belongs_to :account
  belongs_to :vendor
  has_many :payments_bills, :dependent => :destroy

  has_many :bills, :through => :payments_bills

  default_scope order("date DESC")

  accepts_nested_attributes_for :payments_bills, :allow_destroy => true
  
  attr_accessible :date, :memo, :method, :reference , :builder_id, :account_id, :vendor_id, :payments_bills_attributes

  validates_presence_of :vendor, :account, :builder, :method, :date

  METHODS = ["Check", "Debit Card", "Wire", "EFT"]

  def amount
    payments_bills.map(&:amount).compact.sum if payments_bills.any?
  end

end
