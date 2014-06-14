class AccountingTransaction < ActiveRecord::Base
  belongs_to :transactionable, polymorphic: true
  belongs_to :account

  attr_accessible :transactionable_id, :transactionable_type, :date, :amount, :reconciled, :account_id, :display_priority

  default_scope order("date DESC NULLS LAST, display_priority DESC, created_at DESC")
  scope :unreconciled, where(:reconciled => false)
  scope :reconciled, where(:reconciled => true)
  scope :date_range, lambda { |from_date, to_date| where('date >= ? AND date <= ?', from_date, to_date) }
end
