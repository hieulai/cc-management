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

  after_save :update_transactions

  def update_transactions
    accounting_transactions.where(account_id: account_id_was || account_id).first_or_create.update_attributes({account_id: account_id, date: date, amount: amount.to_f})
  end
end
