class Payment < ActiveRecord::Base

  belongs_to :builder
  belongs_to :account
  belongs_to :vendor
  has_many :bills, :dependent => :nullify, :before_add => :charge_account, :after_remove => :refund_account
  
  attr_accessible :date, :memo, :method, :reference , :builder_id, :account_id, :vendor_id

  validates_presence_of :vendor, :account, :builder, :method, :date

  METHODS = ["Check", "Debit Card", "Wire", "EFT"]

  def amount
    bills.map(&:total_amount).compact.sum if bills.any?
  end

  private
  def charge_account(bill)
    self.account.update_attribute(:balance, self.account.balance - bill.total_amount)
  end

  def refund_account(bill)
    self.account.update_attribute(:balance, self.account.balance + bill.total_amount)
  end

end
