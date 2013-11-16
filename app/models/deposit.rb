class Deposit < ActiveRecord::Base
  belongs_to :builder
  belongs_to :account
  has_many :deposits_receipts, :dependent => :destroy
  has_many :receipts, :through => :deposits_receipts

  attr_accessible :deposit_date, :notes, :account_id, :deposits_receipts_attributes
  accepts_nested_attributes_for :deposits_receipts, :allow_destroy => true

  default_scope order("deposit_date DESC")

  validates_presence_of :account, :builder

  def amount
    deposits_receipts.map(&:amount).compact.sum if deposits_receipts.any?
  end
end
