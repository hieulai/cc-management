# == Schema Information
#
# Table name: un_job_costed_items
#
#  id          :integer          not null, primary key
#  name        :string(255)
#  description :string(255)
#  amount      :decimal(10, 2)
#  bill_id     :integer
#  account_id  :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  deleted_at  :time
#

class UnJobCostedItem < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :bill
  belongs_to :account
  attr_accessible :account_id, :amount, :bill_id, :description, :name

  after_save :update_transactions

  default_scope { order(:created_at) }
  scope :date_range, lambda { |from_date, to_date| joins(:bill).where("bills.billed_date >= ? and bills.billed_date <= ? ", from_date, to_date) }

  POSITIVES = [Account::ASSETS, Account::EXPENSES, Account::COST_OF_GOODS_SOLD]
  NEGATIVES = [Account::LIABILITIES, Account::EQUITY, Account::REVENUE]

  def paid?
    bill.paid?
  end

  def date
    bill.billed_date
  end

  def account_amount(a, r_account)
    (a || 0) * (r_account.kind_of?(NEGATIVES) ? -1 : 1)
  end

  def update_transactions
    if account_id_was
      bat_was = bill.accounting_transactions.where(account_id: account_id_was).first
      if bat_was
        account_was = Account.find(account_id_was)
        bat_was.update_attributes({date: date, amount: bat_was.amount.to_f - account_amount(amount_was, account_was)})
        bat_was.destroy if bill.un_job_costed_items.where(account_id: account_id_was).empty?
      end
    end
    bat = bill.accounting_transactions.where(account_id: account_id).first_or_create
    bat.update_attributes({date: date, amount: bat.amount.to_f + account_amount(amount, account)})
  end

  def destroy_transactions
    bill.accounting_transactions.where(account_id: account_id_was).destroy_all if bill.un_job_costed_items.where(account_id: account_id_was).empty?
  end
end
