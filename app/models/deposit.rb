class Deposit < ActiveRecord::Base
  belongs_to :builder, :class_name => "Base::Builder"
  belongs_to :account
  has_many :deposits_receipts, :dependent => :destroy
  has_many :receipts, :through => :deposits_receipts
  has_many :accounting_transactions, as: :transactionable, dependent: :destroy

  attr_accessible :date, :notes, :reconciled, :account_id, :builder_id,
                  :deposits_receipts_attributes, :reference, :cached_total_amount
  accepts_nested_attributes_for :deposits_receipts, :allow_destroy => true

  default_scope order("date DESC")
  scope :date_range, lambda { |from_date, to_date| where('date >= ? AND date <= ?', from_date, to_date) }
  after_save :update_transactions

  validates_presence_of :account, :builder, :date

  searchable do
    text :reference, :notes
    integer :builder_id
    text :date_t do |r|
      r.date.try(:strftime, Date::DATE_FORMATS[:default])
    end
    text :account_name do
      account_name
    end
  end

  def account_name
    account.try(:name)
  end

  def amount
    deposits_receipts.map(&:amount).compact.sum if deposits_receipts.any?
  end

  private
  def update_transactions
    accounting_transactions.where(account_id: builder.deposits_held_account.id).first_or_create.update_attributes({date: date, amount: amount.to_f * -1})
    accounting_transactions.where(account_id: account_id_was|| account_id).first_or_create.update_attributes({account_id: account_id, date: date, amount: amount.to_f})
  end
end
