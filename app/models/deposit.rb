# == Schema Information
#
# Table name: deposits
#
#  id                  :integer          not null, primary key
#  builder_id          :integer
#  account_id          :integer
#  date                :date
#  notes               :text
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  reference           :string(255)
#  cached_total_amount :decimal(10, 2)
#  deleted_at          :time
#

class Deposit < ActiveRecord::Base
  acts_as_paranoid
  include Cacheable
  belongs_to :builder, :class_name => "Base::Builder"
  belongs_to :account

  has_many :deposits_receipts, :dependent => :destroy
  has_many :receipts, :through => :deposits_receipts
  has_many :accounting_transactions, as: :transactionable, dependent: :destroy

  attr_accessible :date, :notes, :account_id, :builder_id,
                  :deposits_receipts_attributes, :reference, :cached_total_amount
  accepts_nested_attributes_for :deposits_receipts, :allow_destroy => true

  default_scope order("date DESC")
  scope :date_range, lambda { |from_date, to_date| where('date >= ? AND date <= ?', from_date, to_date) }
  after_save :update_transactions

  validates_presence_of :account, :builder, :date

  searchable do
    integer :builder_id
    integer :reference
    date :date
    string :account_name do
      account_name
    end
    float :amount do
      amount
    end
    string :notes


    text :reference, :notes
    text :date_t do |r|
      r.date.try(:strftime, Date::DATE_FORMATS[:default])
    end
    text :amount_t do
      sprintf('%.2f', amount.to_f)
    end
    text :account_name do
      account_name
    end
  end

  def account_name
    account.try(:name)
  end

  def total_amount
    amount
  end

  def amount
    deposits_receipts.reject(&:marked_for_destruction?).map(&:amount).compact.sum if deposits_receipts.reject(&:marked_for_destruction?).any?
  end

  private
  def update_transactions
    accounting_transactions.where(account_id: builder.deposits_held_account.id).first_or_create.update_attributes({date: date, amount: amount.to_f * -1})
    accounting_transactions.where(account_id: account_id_was|| account_id).first_or_create.update_attributes({account_id: account_id, date: date, amount: amount.to_f})
  end
end
