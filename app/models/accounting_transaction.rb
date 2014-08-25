# == Schema Information
#
# Table name: accounting_transactions
#
#  id                   :integer          not null, primary key
#  name                 :string(255)
#  transactionable_id   :integer
#  transactionable_type :string(255)
#  date                 :date
#  amount               :decimal(10, 2)
#  reconciled           :boolean          default(FALSE)
#  account_id           :integer
#  display_priority     :integer          default(1)
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  payer_id             :integer
#  payer_type           :string(255)
#  project_id           :integer
#  deleted_at           :time
#

class AccountingTransaction < ActiveRecord::Base
  acts_as_paranoid
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
  scope :accounts, lambda { |account_ids, transactionable_ids=nil, transactionable_type=nil| where('account_id IN (?) OR (transactionable_id IN (?) AND transactionable_type = ?)', account_ids, transactionable_ids, transactionable_type) }
  scope :payer_accounts, lambda { |payer_id, payer_type| where(:payer_id => payer_id, :payer_type => payer_type) }
  scope :project_accounts, lambda { |project_id| where(:project_id => project_id) }
  scope :non_project_accounts, where(:project_id => nil)
  scope :non_payer_accounts, where(payer_id: nil, payer_type: nil)

  after_destroy :update_indexes, :if => Proc.new { |at| at.payer.present? }
  after_save :update_indexes, :if => Proc.new { |at| at.payer.present? }

  def update_indexes
    Sunspot.delay.index payer
  end
end
