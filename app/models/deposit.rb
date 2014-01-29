class Deposit < ActiveRecord::Base
  belongs_to :builder, :class_name => "Base::Builder"
  belongs_to :account
  has_many :deposits_receipts, :dependent => :destroy
  has_many :receipts, :through => :deposits_receipts

  attr_accessible :date, :notes, :reconciled, :from_receipt, :account_id, :builder_id, :deposits_receipts_attributes, :reference
  accepts_nested_attributes_for :deposits_receipts, :allow_destroy => true
  attr_accessor :from_receipt

  default_scope order("date DESC")

  after_update :update_account_balance, :if => :account_id_changed?

  validates_presence_of :account, :builder
  validates_presence_of :date, :if => Proc.new { |r| r.from_receipt }

  def amount
    deposits_receipts.map(&:amount).compact.sum if deposits_receipts.any?
  end

  def method
      "Deposit"
  end

  def memo
    notes
  end

  def payee

  end

  private
  def update_account_balance
    old_account = Account.find(account_id_was)
    account = Account.find(account_id)
    deposits_receipts.each do |dr|
      old_account.update_attribute(:balance, old_account.balance.to_f - dr.amount)
      account.update_attribute(:balance, account.balance.to_f + dr.amount)
    end
  end
end
