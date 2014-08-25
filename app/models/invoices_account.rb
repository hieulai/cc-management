# == Schema Information
#
# Table name: invoices_accounts
#
#  id         :integer          not null, primary key
#  account_id :integer
#  invoice_id :integer
#  date       :date
#  amount     :decimal(10, 2)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  deleted_at :time
#

class InvoicesAccount < ActiveRecord::Base
  acts_as_paranoid
  belongs_to :account
  belongs_to :invoice
  has_many :invoices_items
  has_many :accounting_transactions, as: :transactionable, dependent: :destroy

  attr_accessible :date, :amount, :account_id, :invoice_id

  before_update :remove_old_transactions
  after_save :update_transactions

  def update_transactions
    accounting_transactions.create(account_id: account_id, date: date, amount: amount.to_f)
    accounting_transactions.create(account_id: account_id, project_id: invoice.project.try(:id), date: date, amount: amount.to_f)
  end

  def remove_old_transactions
    accounting_transactions.destroy_all
  end
end
