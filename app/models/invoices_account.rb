class InvoicesAccount < ActiveRecord::Base
  belongs_to :account
  belongs_to :invoice
  has_many :invoices_items
  has_many :accounting_transactions, as: :transactionable, dependent: :destroy

  attr_accessible :date, :amount, :account_id, :invoice_id

  after_save :update_transactions

  def update_transactions
    accounting_transactions.where(account_id: account_id_was || account_id).first_or_create.update_attributes({account_id: account_id, date: date, amount: amount.to_f})
    Sunspot.delay.index accounting_transactions
  end
end
