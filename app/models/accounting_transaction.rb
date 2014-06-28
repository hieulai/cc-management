class AccountingTransaction < ActiveRecord::Base
  belongs_to :transactionable, polymorphic: true
  belongs_to :payer, polymorphic: true
  belongs_to :account
  belongs_to :project

  attr_accessible :transactionable_id, :transactionable_type, :date, :amount, :reconciled, :account_id, :display_priority,
                  :payer_id, :payer_type, :project_id

  default_scope order("date DESC NULLS LAST, display_priority DESC, created_at DESC")
  scope :unreconciled, where(:reconciled => false)
  scope :reconciled, where(:reconciled => true)
  scope :date_range, lambda { |from_date, to_date| where('date >= ? AND date <= ?', from_date, to_date) }
  scope :accounts, lambda { |account_ids, transactionable_ids, transactionable_type| where('account_id IN (?) OR transactionable_id IN (?) AND transactionable_type = ?', account_ids, transactionable_ids, transactionable_type) }
  scope :payer_accounts, lambda { |payer_id, payer_type| where(:payer_id => payer_id, :payer_type => payer_type) }
  scope :project_accounts, lambda { |project_id| where(:project_id => project_id) }
end
